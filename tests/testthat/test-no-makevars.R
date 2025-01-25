test_that("build compile commands", {
  skip_if_not(is_unix())
  skip_if_not(has_clang())

  pkg <- withr::local_tempdir()
  fs::dir_copy(test_path("testNoMakevars"), pkg, overwrite = TRUE)

  suppressMessages(build_compile_commands(pkg))

  expect_true(file.exists(file.path(pkg, "src", "compile_commands.json")))
})

test_that("check that right number of entries is produced", {
  skip_if_not(is_unix())
  skip_if_not(has_clang())

  pkg <- withr::local_tempdir()
  fs::dir_copy(test_path("testNoMakevars"), pkg, overwrite = TRUE)

  suppressMessages(build_compile_commands(pkg))

  entries <- jsonlite::fromJSON(file.path(pkg, "src", "compile_commands.json"))

  expect_equal(nrow(entries), 2)
})
