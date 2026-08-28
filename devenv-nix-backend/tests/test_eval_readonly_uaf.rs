#![cfg(feature = "test-nix-store")]
//! Deterministic reproduction of the libexpr-c `readOnlyMode` use-after-free.
//!
//! Upstream fix: NixOS/nix@d5f162d1166f71a8eb1e343727a51fcfb8a88235
//! ("libexpr-c: Fix UAF on readOnlyMode"). Seen in the wild as
//! cachix/devenv#3064 — `devenv shell` failing with
//! `error: path '/nix/store/...-CVE-2026-8376.patch' is not valid`.
//!
//! Bug: `nix_eval_state_builder` owns a plain `bool readOnlyMode` member;
//! `EvalSettings` stores a `bool &` into it; `nix_eval_state_build` moves
//! the settings into the long-lived `EvalState`; the Rust side then frees
//! the builder (`EvalStateBuilder::drop`). Every later
//! `EvalState::copyPathToStore` dereferences the freed byte to pick
//! `FetchMode::DryRun` (hash only) vs `FetchMode::Copy` (add to store).
//! When the reclaimed byte reads nonzero, source paths are hashed but
//! never added to the store, and any later validation — here `import` ->
//! `realisePath` -> `realiseContext` -> `ensureValid` — throws
//! `InvalidPathError("path '...' is not valid")`.
//!
//! In CI the freed chunk is reclaimed only sometimes (see below for the
//! glibc mechanics), which is why the flake was misread as a
//! two-Nix-versions store disagreement. This test makes it deterministic:
//! after `build()` drops the builder, the first allocation claims the freed
//! chunk whole with a 0x01-filled request of exactly
//! `sizeof(nix_eval_state_builder)`, so the dangling byte reads `true`.
//!
//! Expected outcome (64 rounds each):
//!   - vulnerable libnixexpr (cachix/nix `devenv-2.34` line — what devenv
//!     2.2.x shipped, e.g. rev 59407321 = libnixexprc 2.34.8):
//!     64/64 rounds fail with "is not valid".
//!   - fixed libnixexpr (`devenv-2.35` line or the upstream fix): 0/64,
//!     every round imports the file normally.
//!
//! Knobs:
//!   - `UAF_REPRO_MUST_TRIGGER=1`: assert reproduction (for proving the
//!     bug against a vulnerable build). Default off — the test only asserts
//!     that any failure carries the exact signature, so it stays green on
//!     fixed builds as a regression tripwire.
//!   - `UAF_REPRO_NO_SPRAY=1`: control variant without the heap spray —
//!     the natural allocator-reuse coin flip as seen in CI (in this tight
//!     loop it settles to 0 hits; klangk CI's messier allocation history
//!     is what flips it).

use nix_bindings_expr::eval_state::{EvalStateBuilder, gc_register_my_thread};
use nix_bindings_store::store::Store;

/// Claim the freed `nix_eval_state_builder` chunk with an exact-size,
/// 0x01-filled allocation.
///
/// Measured against the cachix/nix 59407321 headers (what devenv 2.2.2
/// shipped): sizeof(nix_eval_state_builder) = 5736,
/// offsetof(readOnlyMode) = 5728 — the last 8-byte slot of the struct.
///
/// The chunk is far beyond tcache range, so on free it lands in the
/// *unsorted bin* and its tail overlaps the next chunk's `prev_size`
/// (which glibc immediately writes — the dangling byte briefly reads
/// the low byte of the chunk size). A smaller request than the exact
/// size would split the chunk and strand that tail in an unallocated
/// remainder, so the first allocation after the free must request
/// exactly 5736 bytes and claim it whole; `vec![1u8; 5736]` then
/// rewrites every byte including offset 5728, and the dangling `bool &`
/// reads `true`.
fn spray_freed_builder_chunk(into: &mut Vec<Box<[u8]>>) {
    // Tiling: 64 exact-size claims. The first covers the unconsolidated
    // case; if the freed chunk backward-consolidated with a free
    // predecessor of size K, sequential exact-size requests carve the
    // merged chunk front-to-back in 5744-byte windows, so the request
    // ceil((K + 5729) / 5744) lands on the dangling byte. 64 claims tile
    // ~366 KB, far beyond any plausible K.
    for _ in 0..64 {
        let exact = vec![1u8; 5736];
        into.push(exact.into_boxed_slice()); // no realloc: len == capacity
    }
}

#[test]
fn eval_readonly_mode_uaf_repro() {
    nix_bindings_expr::eval_state::init().expect("nix init");
    let _gc_registration = gc_register_my_thread();

    let dir = tempfile::tempdir().expect("tempdir");
    let src = dir.path().join("uaf-src.txt");
    let base = dir.path().to_str().expect("utf8 tempdir");

    // NOTE: string interpolation (not `toString`) — `"${./file}"` coerces the
    // path through copyPathToStore; `toString ./file` would stringify the
    // literal path and never touch the store at all.
    let expr = r#"(import "${./uaf-src.txt}")"#;

    let no_spray = std::env::var("UAF_REPRO_NO_SPRAY").ok().as_deref() == Some("1");

    let rounds = 64;
    let mut ok = 0;
    let mut uaf_hits = 0;
    // Reserved before any builder is allocated: container growth must not
    // race the spray for the freed chunk.
    let mut keep: Vec<Box<[u8]>> = Vec::with_capacity(64 * 65);
    for round in 0..rounds {
        // Fresh content every round: the store path is the NAR hash of the
        // file, so a Copy-mode round that adds its path to the store must
        // not make a later DryRun round's (different) path valid. With
        // shared content the whole run would hinge on round 0 alone.
        std::fs::write(&src, format!("{}\n", 1000 + round).as_bytes()).expect("write src file");

        let store = Store::open(None, []).expect("open store");
        // Same shape as production code (`EvalStateBuilder::new(store)?...build()?`):
        // the builder temporary is freed as soon as build() returns, leaving
        // EvalSettings::readOnlyMode dangling inside the long-lived EvalState.
        let mut eval_state = EvalStateBuilder::new(store)
            .expect("builder")
            .base_directory(base)
            .expect("base directory")
            .build()
            .expect("build eval state");

        // Control mode: without the spray the corrupted read depends on
        // natural allocator reuse — the CI coin flip.
        if !no_spray {
            spray_freed_builder_chunk(&mut keep);
        }

        match eval_state.eval_from_string(expr, base) {
            Ok(_) => ok += 1,
            Err(e) => {
                let msg = format!("{e:#}");
                eprintln!("round {round}: eval failed: {msg}");
                assert!(
                    msg.contains("is not valid"),
                    "unexpected failure (not the UAF signature): {msg}"
                );
                uaf_hits += 1;
            }
        }
    }

    eprintln!(
        "uaf repro ({}): {ok}/{rounds} rounds ok, {uaf_hits}/{rounds} hit the UAF",
        if no_spray {
            "no-spray control"
        } else {
            "spray"
        }
    );

    if std::env::var("UAF_REPRO_MUST_TRIGGER").ok().as_deref() == Some("1") {
        assert!(
            uaf_hits > 0,
            "expected at least one 'is not valid' failure against a vulnerable libnixexpr"
        );
    } else if uaf_hits == 0 {
        eprintln!("no UAF observed: linked libnixexpr contains the fix (ref-counted readOnlyMode)");
    }
}
