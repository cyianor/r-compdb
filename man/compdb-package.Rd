% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compdb-package.R
\docType{package}
\name{compdb-package}
\alias{compdb}
\alias{compdb-package}
\title{Generate Compilation Database for Use with Clang Tools}
\description{
Many modern C/C++ development tools in the 'clang' toolchain, such as 'clang-tidy' or 'clangd', rely on the presence of a compilation database in JSON format \url{https://clang.llvm.org/docs/JSONCompilationDatabase.html}. This package temporarily injects additional build flags into the R build process to generate such a compilation database.
}
\seealso{
Useful links:
\itemize{
  \item \url{https://github.com/cyianor/r-compdb}
  \item Report bugs at \url{https://github.com/cyianor/r-compdb/issues}
}

}
\author{
Felix Held
}
\keyword{internal}
