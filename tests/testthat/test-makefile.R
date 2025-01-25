test_that("abort build compile commands", {
  skip_if_not(is_unix())
  skip_if_not(has_clang())

  pkg <- withr::local_tempdir()
  fs::dir_copy(test_path("testMakefile"), pkg, overwrite = TRUE)

  expect_error(
    suppressMessages(build_compile_commands(pkg)),
    "Package is using a Makefile"
  )
})
