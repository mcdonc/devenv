# Repro: libexpr-c `readOnlyMode` use-after-free (cachix/devenv#3064)

Deterministic reproduction of the intermittent CI failure

```
error: path '/nix/store/<hash>-CVE-2026-8376.patch' is not valid
```

that hits any devenv-based workflow whose devenv embeds the nix 2.34 line
(e.g. klangk's `devenv-setup`, devenv 2.2.x — embedded `libnixexprc.so.2.34.8`,
cachix/nix@`59407321`).

## The bug

`nix_eval_state_builder` (libexpr-c) owns a plain `bool readOnlyMode` member,
and its `EvalSettings` stores a `bool &` into it. `nix_eval_state_build`
moves the settings into the long-lived `EvalState`; the Rust bindings then
free the builder (`EvalStateBuilder::drop`). Every later
`EvalState::copyPathToStore` dereferences the freed byte to choose
`FetchMode::DryRun` (hash only) vs `FetchMode::Copy` (add to store). When
the reclaimed byte reads nonzero, source files are hashed but never added to
the store, and the next validation of one of those paths — `import` ->
`realisePath` -> `realiseContext` -> `ensureValid` — throws
`InvalidPathError("path '...' is not valid")`.

Why CI is intermittent: after the free, the dangling byte (offset 5728 of
the 5736-byte chunk — the struct's last member) briefly *is* glibc metadata
(the next chunk's `prev_size`, which reads as the low byte of the chunk
size, nonzero). What it reads by the time `copyPathToStore` runs depends on
which allocation reclaims that region in between — a coin flip decided by
unrelated allocation history, which is why it was misread as a
two-Nix-versions-sharing-one-store problem. The host nix version is
irrelevant.

Fixed upstream by NixOS/nix@d5f162d1166f71a8eb1e343727a51fcfb8a88235
("libexpr-c: Fix UAF on readOnlyMode" — the bool becomes ref-counted).
The fix is in cachix/nix `devenv-2.35`; it was never backported to
`devenv-2.34`.

## The repro

`test_eval_readonly_uaf.rs` in this directory. It builds an `EvalState`
through the normal builder flow (builder freed at the statement's semicolon,
exactly like production), then makes the first allocations after the free
claim the freed region with 64 exact-size, 0x01-filled requests of
`sizeof(nix_eval_state_builder)` (5736) — tiling so that even if the freed
chunk backward-consolidated with a free predecessor, some request lands on
the dangling byte (offset 5728). It then evaluates `(import "${./uaf-src.txt}")`.
Note the string interpolation: `toString ./file` stringifies the literal
path and never calls `copyPathToStore`.

Each round writes different file content — the store path is the NAR hash,
so with shared content a single Copy-mode round would add the path to the
store and silently immunize every later DryRun round.

Knobs: `UAF_REPRO_MUST_TRIGGER=1` asserts the bug reproduces (use against
vulnerable libs); `UAF_REPRO_NO_SPRAY=1` runs the no-spray control.

## How to run both sides

The vulnerable/fixed outcome is decided solely by which libnixexpr the test
links, i.e. by what the checked-out tree's devenv flake pins (`nix.dev`
provides the pkg-config'd libs to the bindings' build).

Vulnerable side (devenv 2.2.2's exact generation — expects 64/64 hits):

```bash
git checkout v2.2.2   # any commit whose flake.lock pins the devenv-2.34 line
git checkout i3064-repro -- devenv-nix-backend/tests/test_eval_readonly_uaf.rs
UAF_REPRO_MUST_TRIGGER=1 CARGO_TARGET_DIR=target-vuln \
  devenv shell -- cargo test -p devenv-nix-backend --features test-nix-store \
    --test test_eval_readonly_uaf -- --nocapture
# uaf repro (spray): 0/64 rounds ok, 64/64 hit the UAF
#   error: path '<hash>-uaf-src.txt' is not valid
```

Fixed side (current main, devenv-2.35 libs — the regression tripwire,
expects 0/64):

```bash
git checkout i3064-repro
devenv shell -- cargo test -p devenv-nix-backend --features test-nix-store \
  --test test_eval_readonly_uaf -- --nocapture
# uaf repro (spray): 64/64 rounds ok, 0/64 hit the UAF
```

Use a fresh `CARGO_TARGET_DIR` when switching sides: the bindings' build
script probes pkg-config and only re-links when its inputs change.

## `repro-vuln/`

An auxiliary flake pinning the exact vulnerable libs
(`github:cachix/nix/59407321`) plus gcc — handy for inspecting the pinned
generation without switching checkouts:

```bash
nix develop ./repro-vuln --command pkg-config --modversion nix-expr-c   # 2.34.8
# sizeof/offsetof probe against the vendored internal header:
git clone https://github.com/cachix/nix && git -C nix checkout 59407321a92f7d34d4a53e38959294007c0bc37a
nix develop ./repro-vuln --command bash -c \
  'cd nix && g++ -std=c++23 probe.c -Isrc/libexpr-c -Isrc/libutil-c \
     $(pkg-config --cflags nix-expr-c nix-store-c nix-flake-c nix-main-c \
       nix-fetchers-c nix-util-c nix-cmd-c) -o probe && ./probe'
```

(gcc 15 / `-std=c++23` needed for the headers.) Note: current main's Rust
code already uses a 2.35-only C API (`set_eval_effect_callback`), so the
repro-vuln libs cannot link main — run the vulnerable side from a v2.2.x
checkout as above.
