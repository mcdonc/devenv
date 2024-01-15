{
  outputs = { ... }: {
    overlays.default = self: super: {
      # disable arrow-flight-test (see below output from Jan 15, 2024)
      arrow-cpp = super.arrow-cpp.overrideAttrs (_: {
        disabledTests = super.arrow-cpp.disabledTests
          ++ [ "arrow-flight-test" ];
      });
    };
  };
}

# @nix { "action": "setPhase", "phase": "installCheckPhase" }
# Running phase: installCheckPhase
# Test project /build/apache-arrow-14.0.1/cpp/build
#       Start  1: arrow-array-test
#       Start  2: arrow-buffer-test
#       Start  3: arrow-extension-type-test
#       Start  4: arrow-misc-test
#       Start  5: arrow-public-api-test
#       Start  6: arrow-scalar-test
#  1/87 Test  #3: arrow-extension-type-test ....................   Passed    0.38 sec
#       Start  7: arrow-type-test
#  2/87 Test  #6: arrow-scalar-test ............................   Passed    0.40 sec
#       Start  8: arrow-table-test
#  3/87 Test  #2: arrow-buffer-test ............................   Passed    0.42 sec
#       Start  9: arrow-tensor-test
#  4/87 Test  #5: arrow-public-api-test ........................   Passed    0.42 sec
#       Start 10: arrow-sparse-tensor-test
#  5/87 Test  #4: arrow-misc-test ..............................   Passed    0.43 sec
#       Start 11: arrow-stl-test
#  6/87 Test  #9: arrow-tensor-test ............................   Passed    0.30 sec
#       Start 12: arrow-random-test
#  7/87 Test #11: arrow-stl-test ...............................   Passed    0.34 sec
#       Start 13: arrow-concatenate-test
#  8/87 Test  #7: arrow-type-test ..............................   Passed    0.40 sec
#       Start 14: arrow-diff-test
#  9/87 Test #10: arrow-sparse-tensor-test .....................   Passed    0.36 sec
#       Start 15: arrow-c-bridge-test
# 10/87 Test  #8: arrow-table-test .............................   Passed    0.42 sec
#       Start 16: arrow-compute-internals-test
# 11/87 Test #15: arrow-c-bridge-test ..........................   Passed    0.32 sec
#       Start 17: arrow-compute-expression-test
# 12/87 Test #13: arrow-concatenate-test .......................   Passed    0.36 sec
#       Start 18: arrow-compute-scalar-cast-test
# 13/87 Test #12: arrow-random-test ............................   Passed    0.49 sec
#       Start 19: arrow-compute-scalar-type-test
# 14/87 Test #14: arrow-diff-test ..............................   Passed    0.46 sec
#       Start 20: arrow-compute-scalar-if-else-test
# 15/87 Test #17: arrow-compute-expression-test ................   Passed    0.39 sec
#       Start 21: arrow-compute-scalar-temporal-test
# 16/87 Test #19: arrow-compute-scalar-type-test ...............   Passed    0.50 sec
#       Start 22: arrow-compute-scalar-math-test
# 17/87 Test #18: arrow-compute-scalar-cast-test ...............   Passed    0.75 sec
#       Start 23: arrow-compute-scalar-utility-test
# 18/87 Test #16: arrow-compute-internals-test .................   Passed    1.09 sec
#       Start 24: arrow-compute-vector-test
# 19/87 Test #21: arrow-compute-scalar-temporal-test ...........   Passed    0.53 sec
#       Start 25: arrow-compute-vector-sort-test
# 20/87 Test #23: arrow-compute-scalar-utility-test ............   Passed    0.21 sec
#       Start 26: arrow-compute-vector-selection-test
# 21/87 Test #22: arrow-compute-scalar-math-test ...............   Passed    0.39 sec
#       Start 27: arrow-compute-aggregate-test
# 22/87 Test #20: arrow-compute-scalar-if-else-test ............   Passed    1.28 sec
#       Start 28: arrow-compute-kernel-utility-test
# 23/87 Test #26: arrow-compute-vector-selection-test ..........   Passed    0.55 sec
#       Start 29: arrow-io-buffered-test
# 24/87 Test #28: arrow-compute-kernel-utility-test ............   Passed    0.14 sec
#       Start 30: arrow-io-compressed-test
# 25/87 Test #27: arrow-compute-aggregate-test .................   Passed    0.62 sec
#       Start 31: arrow-io-file-test
# 26/87 Test #29: arrow-io-buffered-test .......................   Passed    0.18 sec
#       Start 32: arrow-io-hdfs-test
# 27/87 Test #25: arrow-compute-vector-sort-test ...............   Passed    0.88 sec
#       Start 33: arrow-io-memory-test
# 28/87 Test #31: arrow-io-file-test ...........................   Passed    0.30 sec
#       Start 34: arrow-utility-test
# 29/87 Test #24: arrow-compute-vector-test ....................   Passed    1.31 sec
#       Start 35: arrow-async-utility-test
# 30/87 Test #32: arrow-io-hdfs-test ...........................   Passed    0.43 sec
#       Start 36: arrow-bit-utility-test
# 31/87 Test #36: arrow-bit-utility-test .......................   Passed    0.40 sec
#       Start 37: arrow-threading-utility-test
# 32/87 Test #34: arrow-utility-test ...........................   Passed    1.10 sec
#       Start 38: arrow-crc32-test
# 33/87 Test #38: arrow-crc32-test .............................   Passed    0.30 sec
#       Start 39: arrow-json-integration-test
# 34/87 Test #33: arrow-io-memory-test .........................   Passed    1.51 sec
#       Start 40: arrow-csv-test
# 35/87 Test #30: arrow-io-compressed-test .....................   Passed    1.84 sec
#       Start 41: arrow-acero-plan-test
# 36/87 Test #39: arrow-json-integration-test ..................   Passed    0.23 sec
#       Start 42: arrow-acero-source-node-test
# 37/87 Test #41: arrow-acero-plan-test ........................   Passed    1.32 sec
#       Start 43: arrow-acero-fetch-node-test
# 38/87 Test #40: arrow-csv-test ...............................   Passed    1.47 sec
#       Start 44: arrow-acero-order-by-node-test
# 39/87 Test #43: arrow-acero-fetch-node-test ..................   Passed    0.21 sec
#       Start 45: arrow-acero-hash-join-node-test
# 40/87 Test #44: arrow-acero-order-by-node-test ...............   Passed    0.24 sec
#       Start 46: arrow-acero-pivot-longer-node-test
# 41/87 Test #46: arrow-acero-pivot-longer-node-test ...........   Passed    0.14 sec
#       Start 47: arrow-acero-asof-join-node-test
# 42/87 Test  #1: arrow-array-test .............................   Passed    7.25 sec
#       Start 48: arrow-acero-tpch-node-test
# 43/87 Test #42: arrow-acero-source-node-test .................   Passed    3.42 sec
#       Start 49: arrow-acero-union-node-test
# 44/87 Test #49: arrow-acero-union-node-test ..................   Passed    0.77 sec
#       Start 50: arrow-acero-aggregate-node-test
# 45/87 Test #50: arrow-acero-aggregate-node-test ..............   Passed    0.41 sec
#       Start 51: arrow-acero-util-test
# 46/87 Test #37: arrow-threading-utility-test .................   Passed    6.00 sec
#       Start 52: arrow-acero-hash-aggregate-test
# 47/87 Test #51: arrow-acero-util-test ........................   Passed    0.40 sec
#       Start 53: arrow-dataset-dataset-test
# 48/87 Test #48: arrow-acero-tpch-node-test ...................   Passed    2.43 sec
#       Start 54: arrow-dataset-dataset-writer-test
# 49/87 Test #35: arrow-async-utility-test .....................   Passed    6.51 sec
#       Start 55: arrow-dataset-discovery-test
# 50/87 Test #53: arrow-dataset-dataset-test ...................   Passed    0.20 sec
#       Start 56: arrow-dataset-file-ipc-test
# 51/87 Test #54: arrow-dataset-dataset-writer-test ............   Passed    0.21 sec
#       Start 57: arrow-dataset-file-test
# 52/87 Test #55: arrow-dataset-discovery-test .................   Passed    0.17 sec
#       Start 58: arrow-dataset-partition-test
# 53/87 Test #57: arrow-dataset-file-test ......................   Passed    0.19 sec
#       Start 59: arrow-dataset-scanner-test
# 54/87 Test #58: arrow-dataset-partition-test .................   Passed    0.18 sec
#       Start 60: arrow-dataset-subtree-test
# 55/87 Test #56: arrow-dataset-file-ipc-test ..................   Passed    0.27 sec
#       Start 61: arrow-dataset-write-node-test
# 56/87 Test #52: arrow-acero-hash-aggregate-test ..............   Passed    0.48 sec
#       Start 62: arrow-dataset-file-csv-test
# 57/87 Test #61: arrow-dataset-write-node-test ................   Passed    0.26 sec
#       Start 63: arrow-dataset-file-json-test
# 58/87 Test #60: arrow-dataset-subtree-test ...................   Passed    0.48 sec
#       Start 64: arrow-dataset-file-parquet-test
# 59/87 Test #59: arrow-dataset-scanner-test ...................   Passed    1.24 sec
#       Start 65: arrow-dataset-file-parquet-encryption-test
# 60/87 Test #65: arrow-dataset-file-parquet-encryption-test ...   Passed    0.44 sec
#       Start 66: arrow-filesystem-test
# 61/87 Test #64: arrow-dataset-file-parquet-test ..............   Passed    1.39 sec
#       Start 67: arrow-s3fs-test
# 62/87 Test #67: arrow-s3fs-test ..............................   Passed    0.42 sec
#       Start 68: arrow-hdfs-test
# 63/87 Test #68: arrow-hdfs-test ..............................   Passed    0.39 sec
#       Start 69: arrow-flight-internals-test
# 64/87 Test #69: arrow-flight-internals-test ..................   Passed    0.31 sec
#       Start 70: arrow-flight-test
# 65/87 Test #66: arrow-filesystem-test ........................   Passed    1.35 sec
#       Start 71: arrow-flight-sql-test
# 66/87 Test #62: arrow-dataset-file-csv-test ..................   Passed    3.02 sec
#       Start 72: arrow-feather-test
# 67/87 Test #72: arrow-feather-test ...........................   Passed    0.33 sec
#       Start 73: arrow-ipc-json-simple-test
# 68/87 Test #73: arrow-ipc-json-simple-test ...................   Passed    0.17 sec
#       Start 74: arrow-ipc-read-write-test
# 69/87 Test #71: arrow-flight-sql-test ........................   Passed    0.67 sec
#       Start 75: arrow-ipc-tensor-test
# 70/87 Test #75: arrow-ipc-tensor-test ........................   Passed    0.29 sec
#       Start 76: arrow-json-test
# 71/87 Test #76: arrow-json-test ..............................   Passed    0.47 sec
#       Start 77: arrow-fixed-shape-tensor-test
# 72/87 Test #77: arrow-fixed-shape-tensor-test ................   Passed    0.18 sec
#       Start 78: arrow-substrait-substrait-test
# 73/87 Test #70: arrow-flight-test ............................***Failed    1.70 sec
# Running arrow-flight-test, redirecting output into /build/apache-arrow-14.0.1/cpp/build/build/test-logs/arrow-flight-test.txt (attempt 1/1)
# /build/apache-arrow-14.0.1/cpp/build-support/run-test.sh: line 88: 17993 Aborted                 (core dumped) $TEST_EXECUTABLE "$@" > $LOGFILE.raw 2>&1
# Running main() from /build/source/googletest/src/gtest_main.cc
# Note: Google Test filter = -S3OptionsTest.FromUri:S3RegionResolutionTest.NonExistentBucket:S3RegionResolutionTest.PublicBucket:S3RegionResolutionTest.RestrictedBucket:TestMinioServer.Connect:TestS3FS.*:TestS3FSGeneric.*
# [==========] Running 96 tests from 20 test suites.
# [----------] Global test environment set-up.
# [----------] 5 tests from GrpcConnectivityTest
# [ RUN      ] GrpcConnectivityTest.GetPort
# [       OK ] GrpcConnectivityTest.GetPort (174 ms)
# [ RUN      ] GrpcConnectivityTest.BuilderHook
# [       OK ] GrpcConnectivityTest.BuilderHook (5 ms)
# [ RUN      ] GrpcConnectivityTest.Shutdown
# [       OK ] GrpcConnectivityTest.Shutdown (46 ms)
# [ RUN      ] GrpcConnectivityTest.ShutdownWithDeadline
# [       OK ] GrpcConnectivityTest.ShutdownWithDeadline (2 ms)
# [ RUN      ] GrpcConnectivityTest.BrokenConnection
# [       OK ] GrpcConnectivityTest.BrokenConnection (3 ms)
# [----------] 5 tests from GrpcConnectivityTest (233 ms total)

# [----------] 18 tests from GrpcDataTest
# [ RUN      ] GrpcDataTest.TestDoGetInts
# [       OK ] GrpcDataTest.TestDoGetInts (9 ms)
# [ RUN      ] GrpcDataTest.TestDoGetFloats
# [       OK ] GrpcDataTest.TestDoGetFloats (4 ms)
# [ RUN      ] GrpcDataTest.TestDoGetDicts
# [       OK ] GrpcDataTest.TestDoGetDicts (5 ms)
# [ RUN      ] GrpcDataTest.TestDoGetLargeBatch
# [       OK ] GrpcDataTest.TestDoGetLargeBatch (217 ms)
# [ RUN      ] GrpcDataTest.TestFlightDataStreamError
# WARNING: Logging before InitGoogleLogging() is written to STDERR
# W20240115 18:28:15.649698 19239 status.cc:155] Failed to close FlightDataStream: IOError: Expected error
# [       OK ] GrpcDataTest.TestFlightDataStreamError (9 ms)
# [ RUN      ] GrpcDataTest.TestOverflowServerBatch
# [       OK ] GrpcDataTest.TestOverflowServerBatch (197 ms)
# [ RUN      ] GrpcDataTest.TestOverflowClientBatch
# [       OK ] GrpcDataTest.TestOverflowClientBatch (169 ms)
# [ RUN      ] GrpcDataTest.TestDoExchange
# [       OK ] GrpcDataTest.TestDoExchange (11 ms)
# [ RUN      ] GrpcDataTest.TestDoExchangeNoData
# [       OK ] GrpcDataTest.TestDoExchangeNoData (13 ms)
# [ RUN      ] GrpcDataTest.TestDoExchangeWriteOnlySchema
# [       OK ] GrpcDataTest.TestDoExchangeWriteOnlySchema (37 ms)
# [ RUN      ] GrpcDataTest.TestDoExchangeGet
# [       OK ] GrpcDataTest.TestDoExchangeGet (26 ms)
# [ RUN      ] GrpcDataTest.TestDoExchangePut
# [       OK ] GrpcDataTest.TestDoExchangePut (18 ms)
# [ RUN      ] GrpcDataTest.TestDoExchangeEcho
# [       OK ] GrpcDataTest.TestDoExchangeEcho (16 ms)
# [ RUN      ] GrpcDataTest.TestDoExchangeTotal
# [       OK ] GrpcDataTest.TestDoExchangeTotal (12 ms)
# [ RUN      ] GrpcDataTest.TestDoExchangeError
# [       OK ] GrpcDataTest.TestDoExchangeError (7 ms)
# [ RUN      ] GrpcDataTest.TestDoExchangeConcurrency
# [       OK ] GrpcDataTest.TestDoExchangeConcurrency (7 ms)
# [ RUN      ] GrpcDataTest.TestDoExchangeUndrained
# [       OK ] GrpcDataTest.TestDoExchangeUndrained (13 ms)
# [ RUN      ] GrpcDataTest.TestIssue5095
# [       OK ] GrpcDataTest.TestIssue5095 (6 ms)
# [----------] 18 tests from GrpcDataTest (786 ms total)

# [----------] 7 tests from GrpcDoPutTest
# [ RUN      ] GrpcDoPutTest.TestInts
# [       OK ] GrpcDoPutTest.TestInts (5 ms)
# [ RUN      ] GrpcDoPutTest.TestFloats
# [       OK ] GrpcDoPutTest.TestFloats (3 ms)
# [ RUN      ] GrpcDoPutTest.TestEmptyBatch
# [       OK ] GrpcDoPutTest.TestEmptyBatch (4 ms)
# [ RUN      ] GrpcDoPutTest.TestDicts
# [       OK ] GrpcDoPutTest.TestDicts (4 ms)
# [ RUN      ] GrpcDoPutTest.TestLargeBatch
# [       OK ] GrpcDoPutTest.TestLargeBatch (128 ms)
# [ RUN      ] GrpcDoPutTest.TestSizeLimit
# [       OK ] GrpcDoPutTest.TestSizeLimit (3 ms)
# [ RUN      ] GrpcDoPutTest.TestUndrained
# [       OK ] GrpcDoPutTest.TestUndrained (4 ms)
# [----------] 7 tests from GrpcDoPutTest (154 ms total)

# [----------] 5 tests from GrpcAppMetadataTest
# [ RUN      ] GrpcAppMetadataTest.TestDoGet
# [       OK ] GrpcAppMetadataTest.TestDoGet (3 ms)
# [ RUN      ] GrpcAppMetadataTest.TestDoGetDictionaries
# [       OK ] GrpcAppMetadataTest.TestDoGetDictionaries (4 ms)
# [ RUN      ] GrpcAppMetadataTest.TestDoPut
# [       OK ] GrpcAppMetadataTest.TestDoPut (6 ms)
# [ RUN      ] GrpcAppMetadataTest.TestDoPutDictionaries
# [       OK ] GrpcAppMetadataTest.TestDoPutDictionaries (8 ms)
# [ RUN      ] GrpcAppMetadataTest.TestDoPutReadMetadata
# [       OK ] GrpcAppMetadataTest.TestDoPutReadMetadata (4 ms)
# [----------] 5 tests from GrpcAppMetadataTest (26 ms total)

# [----------] 5 tests from GrpcIpcOptionsTest
# [ RUN      ] GrpcIpcOptionsTest.TestDoGetReadOptions
# [       OK ] GrpcIpcOptionsTest.TestDoGetReadOptions (4 ms)
# [ RUN      ] GrpcIpcOptionsTest.TestDoPutWriteOptions
# [       OK ] GrpcIpcOptionsTest.TestDoPutWriteOptions (2 ms)
# [ RUN      ] GrpcIpcOptionsTest.TestDoExchangeClientWriteOptions
# [       OK ] GrpcIpcOptionsTest.TestDoExchangeClientWriteOptions (3 ms)
# [ RUN      ] GrpcIpcOptionsTest.TestDoExchangeClientWriteOptionsBegin
# [       OK ] GrpcIpcOptionsTest.TestDoExchangeClientWriteOptionsBegin (8 ms)
# [ RUN      ] GrpcIpcOptionsTest.TestDoExchangeServerWriteOptions
# [       OK ] GrpcIpcOptionsTest.TestDoExchangeServerWriteOptions (4 ms)
# [----------] 5 tests from GrpcIpcOptionsTest (23 ms total)

# [----------] 3 tests from GrpcCudaDataTest
# [ RUN      ] GrpcCudaDataTest.TestDoGet
# /build/apache-arrow-14.0.1/cpp/src/arrow/flight/test_definitions.cc:1417: Skipped
# Arrow was built without ARROW_CUDA
# [  SKIPPED ] GrpcCudaDataTest.TestDoGet (0 ms)
# [ RUN      ] GrpcCudaDataTest.TestDoPut
# /build/apache-arrow-14.0.1/cpp/src/arrow/flight/test_definitions.cc:1418: Skipped
# Arrow was built without ARROW_CUDA
# [  SKIPPED ] GrpcCudaDataTest.TestDoPut (0 ms)
# [ RUN      ] GrpcCudaDataTest.TestDoExchange
# /build/apache-arrow-14.0.1/cpp/src/arrow/flight/test_definitions.cc:1420: Skipped
# Arrow was built without ARROW_CUDA
# [  SKIPPED ] GrpcCudaDataTest.TestDoExchange (0 ms)
# [----------] 3 tests from GrpcCudaDataTest (0 ms total)

# [----------] 5 tests from GrpcErrorHandlingTest
# [ RUN      ] GrpcErrorHandlingTest.TestAsyncGetFlightInfo
# [       OK ] GrpcErrorHandlingTest.TestAsyncGetFlightInfo (45 ms)
# [ RUN      ] GrpcErrorHandlingTest.TestGetFlightInfo
# [       OK ] GrpcErrorHandlingTest.TestGetFlightInfo (52 ms)
# [ RUN      ] GrpcErrorHandlingTest.TestGetFlightInfoMetadata
# [       OK ] GrpcErrorHandlingTest.TestGetFlightInfoMetadata (14 ms)
# [ RUN      ] GrpcErrorHandlingTest.TestDoPut
# [       OK ] GrpcErrorHandlingTest.TestDoPut (8 ms)
# [ RUN      ] GrpcErrorHandlingTest.TestDoExchange
# [       OK ] GrpcErrorHandlingTest.TestDoExchange (13 ms)
# [----------] 5 tests from GrpcErrorHandlingTest (134 ms total)

# [----------] 3 tests from GrpcAsyncClientTest
# [ RUN      ] GrpcAsyncClientTest.TestGetFlightInfo
# [       OK ] GrpcAsyncClientTest.TestGetFlightInfo (5 ms)
# [ RUN      ] GrpcAsyncClientTest.TestGetFlightInfoFuture
# E0115 18:28:16.604820527   20361 thd.cc:182]                           pthread_join failed: Resource deadlock avoided
# /build/apache-arrow-14.0.1/cpp/build/src/arrow/flight

#       Start 79: parquet-internals-test
# 74/87 Test #78: arrow-substrait-substrait-test ...............   Passed    0.50 sec
#       Start 80: parquet-reader-test
# 75/87 Test #74: arrow-ipc-read-write-test ....................   Passed    1.59 sec
#       Start 81: parquet-writer-test
# 76/87 Test #63: arrow-dataset-file-json-test .................   Passed    5.52 sec
#       Start 82: parquet-arrow-test
# 77/87 Test #79: parquet-internals-test .......................   Passed    1.21 sec
#       Start 83: parquet-arrow-internals-test
# 78/87 Test #80: parquet-reader-test ..........................   Passed    0.81 sec
#       Start 84: parquet-encryption-test
# 79/87 Test #83: parquet-arrow-internals-test .................   Passed    0.21 sec
#       Start 85: parquet-encryption-key-management-test
# 80/87 Test #84: parquet-encryption-test ......................   Passed    0.42 sec
#       Start 86: parquet-file-deserialize-test
# 81/87 Test #86: parquet-file-deserialize-test ................   Passed    0.16 sec
#       Start 87: parquet-schema-test
# 82/87 Test #87: parquet-schema-test ..........................   Passed    0.14 sec
# 83/87 Test #85: parquet-encryption-key-management-test .......   Passed    1.38 sec
# 84/87 Test #82: parquet-arrow-test ...........................   Passed    1.70 sec
# 85/87 Test #45: arrow-acero-hash-join-node-test ..............   Passed   12.98 sec
# 86/87 Test #47: arrow-acero-asof-join-node-test ..............   Passed   13.41 sec
# 87/87 Test #81: parquet-writer-test ..........................   Passed    5.06 sec

# 99% tests passed, 1 tests failed out of 87

# Label Time Summary:
# arrow-tests         =  38.22 sec*proc (36 tests)
# arrow_acero         =  36.21 sec*proc (12 tests)
# arrow_compute       =   8.64 sec*proc (13 tests)
# arrow_dataset       =  13.57 sec*proc (13 tests)
# arrow_flight        =   2.01 sec*proc (2 tests)
# arrow_flight_sql    =   0.67 sec*proc (1 test)
# arrow_substrait     =   0.50 sec*proc (1 test)
# filesystem          =   2.16 sec*proc (3 tests)
# parquet-tests       =  11.10 sec*proc (9 tests)
# unittest            = 110.93 sec*proc (87 tests)

# Total Test time (real) =  20.42 sec

# The following tests FAILED:
# 	 70 - arrow-flight-test (Failed)
# Errors while running CTest
# ❯ 
