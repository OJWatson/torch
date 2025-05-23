context("cuda")

test_that("cuda", {
  skip_if_cuda_not_available()

  expect_true(cuda_device_count() > 0)
  expect_true(cuda_current_device() >= 0)
  expect_true(cuda_is_available())

  capability <- cuda_get_device_capability(cuda_current_device())
  expect_type(capability, "integer")
  expect_length(capability, 2)
  expect_error(cuda_get_device_capability(cuda_device_count() + 1), "device must be an integer between 0 and")
})

test_that("cuda tensors", {
  skip_if_cuda_not_available()

  x <- torch_randn(10, 10, device = torch_device("cuda"))

  expect_equal(x$device$type, "cuda")
  expect_equal(x$device$index, 0)
})

test_that("cuda memory stats work", {
  skip_if_cuda_not_available()

  stats <- cuda_memory_stats()
  expect_length(stats, 13)
})

test_that("can empty cache", {
  skip_if_cuda_not_available()

  x <- torch_randn(1000, 1000, device = "cuda")
  stats <- cuda_memory_stats()
  rm(x)
  gc()
  cuda_empty_cache()
  stats_after <- cuda_memory_stats()
  
  expect_true(stats_after$reserved_bytes$all$current < stats$reserved_bytes$all$current)
})

test_that("cuda is really available", {
  # a stop gap test that makes sure cuda is available when it should be
  if (Sys.getenv("TORCH_TEST_CUDA", "0") == "1") {
    expect_true(cuda_is_available())
  }
})

test_that("cuda memory snapshot works", {
  skip_if_cuda_not_available()
  
  cuda_record_memory_history(enabled = "all", max_entries = 1e3)
  x <- torch_randn(16, device="cuda")
  memory <- cuda_memory_snapshot()
  
  expect_true(class(memory) == "raw")
  expect_true(length(memory) > 100)
})
