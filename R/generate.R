#' Check Whether a Clang Toolchain is Being Used
#'
#' @return A logical indicating whether clang is used as a compiler
check_clang <- function() {
  cc <- pkgbuild::rcmd_build_tools("CONFIG", "CC", quiet = TRUE)$stdout
  cxx <- pkgbuild::rcmd_build_tools("CONFIG", "CXX", quiet = TRUE)$stdout
  grepl("clang", cc) && grepl("clang", cxx)
}

#' Determine Path to Makevars File and Check if it Already Exists
#'
#' @param path The path of the package
#'
#' @return A list containing
#'         \item{path}{The absolute path to the Makevars file}
#'         \item{exists}{Whether or not the Makevars file currently exists}
get_makevars <- function(path = ".") {
  src_path <- file.path(path, "src")

  makevars_candidates <- c(
    "Makevars.in", "Makevars", "Makevars.win", "Makevars.ucrt"
  )

  makevars <- NULL
  exists <- FALSE
  for (candidate in makevars_candidates) {
    if (file.exists(file.path(src_path, candidate))) {
      makevars <- file.path(src_path, candidate)
      exists <- TRUE
      break
    }
  }

  if (is.null(makevars)) {
    if (.Platform$OS.type == "windows") {
      makevars <- file.path(src_path, "Makevars.win")
    } else {
      makevars <- file.path(src_path, "Makevars")
    }
  }

  list(
    path = makevars,
    exists = exists
  )
}

#' Generate Compilation Database for Use with Clang Tools
#'
#' @param path The path of the package
#' @param debug Set to TRUE to get verbose output
#'
#' @examples
#' \dontrun{
#' build_compile_commands(path = ".")
#' }
#'
#' @export
build_compile_commands <- function(path = ".", debug = FALSE) {
  if (!check_clang()) {
    cli::cli_abort(c(
      "Clang toolchain required",
      "i" = paste(
        "Ensure that `R CMD CONFIG CXX` points to version of",
        "the clang compiler"
      )
    ))
  }

  if (!pkgbuild::pkg_has_src(path)) {
    cli::cli_abort(c(
      "No src directory found.",
      "i" = "Compilation database not necessary"
    ))
  }

  src_path <- file.path(path, "src")

  # For now, abort for packages using a Makefile
  if (
    file.exists(file.path(src_path, "Makefile"))
    || file.exists(file.path(src_path, "Makefile.win"))
    || file.exists(file.path(src_path, "Makefile.ucrt"))
  ) {
    cli::cli_abort(c(
      "Package is using a Makefile",
      "i" = "compdb currently only works for R packages relying on Makevars"
    ))
  }

  cli::cli_alert_info("Preparing package...")

  pkg_tmpdir <- withr::local_tempdir(pattern = "compdb-pkg")

  pkg <- pkgbuild::build(
    path = path,
    dest_path = pkg_tmpdir,
    binary = FALSE,
    vignettes = FALSE,
    manual = FALSE,
    quiet = !debug
  )

  # Extract files to make path predictable
  pkg_name <- strsplit(basename(pkg), "_", fixed = TRUE)[[1]][1]
  pkg_path <- file.path(pkg_tmpdir, pkg_name)
  utils::untar(pkg, exdir = pkg_tmpdir)

  makevars <- get_makevars(path = pkg_path)

  if (makevars$exists) {
    makevars_tmp <- tempfile()
    file.copy(from = makevars$path, to = makevars_tmp)
  } else {
    file.create(makevars$path)
  }

  json_tmpdir <- withr::local_tempdir(pattern = "compdb-json")
  json_tmpfiles <- file.path(json_tmpdir, "$@.json")

  size <- file.size(makevars$path)
  content <- readChar(makevars$path, size)

  pkg_cppflags <- ""
  if (substr(content, size, size) != "\n") {
    pkg_cppflags <- "\n"
  }
  pkg_cppflags <- paste0(pkg_cppflags, "PKG_CPPFLAGS += -MJ ", json_tmpfiles)

  f <- file(makevars$path, "a+")
  write(
    pkg_cppflags,
    file = f,
    append = TRUE
  )
  close(f)

  cli::cli_alert_info("Installing package to temporary location...")

  withr::local_temp_libpaths()

  callr::rcmd_safe(
    cmd = "INSTALL",
    cmdargs = c(
      "--clean",
      "--preclean",
      pkg_path
    ),
    echo = debug,
    show = debug,
    fail_on_status = TRUE,
    stderr = "2>&1"
  )

  files <- sapply(list.files(json_tmpdir, pattern = "\\.json$"), function(f) {
    content <- readLines(file.path(json_tmpdir, f))
    # Files usually end with a `,`, remove it
    if (substr(content, nchar(content), nchar(content)) == ",") {
      content <- substr(content, 1, nchar(content) - 1)
    }

    sub(
      tools::file_path_as_absolute(pkg_path),
      tools::file_path_as_absolute(path),
      content,
      fixed = TRUE
    )
  })
  write(
    paste0("[", paste(files, collapse = ",\n"), "]"),
    file = file.path(path, "src", "compile_commands.json")
  )

  cli::cli_alert_success("Compilation database successfully generated.")
}
