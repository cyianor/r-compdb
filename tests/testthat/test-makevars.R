test_that("build compile commands with Makevars", {
  pkg <- withr::local_tempdir()
  fs::dir_copy(test_path("testMakevars"), pkg, overwrite = TRUE)

  suppressMessages(build_compile_commands(pkg))

  expect_true(file.exists(file.path(pkg, "src", "compile_commands.json")))
})

test_that("check that right number of entries is produced", {
  pkg <- withr::local_tempdir()
  fs::dir_copy(test_path("testMakevars"), pkg, overwrite = TRUE)

  suppressMessages(build_compile_commands(pkg))

  entries <- jsonlite::fromJSON(file.path(pkg, "src", "compile_commands.json"))

  expect_equal(nrow(entries), 2)
})
