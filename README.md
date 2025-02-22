# compdb

Many modern C++ development tools in the clang/LLVM toolchain, such as
clang-tidy or clangd, rely on the presence of a [compilation database in
JSON format](https://clang.llvm.org/docs/JSONCompilationDatabase.html).
This package temporarily injects additional build flags into the R build
process to generate such a compilation database.

## Caveats

1.  A full package build including compilation is necessary to generate
    the compilation database.
2.  This package is purely meant for platforms that support R built with clang,
    which essentially excludes Windows. Rtools is built around GCC and I am
    not aware of clang being used within the R world on Windows.
3.  Currently, this method only works for packages utilizing the
    standard R build process, i.e. the only modifications to the build
    process come in the form of `Makevars`, or the configurable
    variant `Makevars.in`, in the package’s `src` directory. This
    supports a broad range of packages since it allows for custom
    `configure` files as long as they do not create a `Makevars` file
    from scratch but rather modify a `Makevars.in`.

    For packages using their own custom `Makefile`s, additional effort
    from the package authors side may be necessary to generate the
    compilation database(s).

## Installation

You can install the development version of compdb like so:

``` r
remotes::install_github("cyianor/r-compdb")
```

You can install the current stable version of compdb from CRAN like so:

``` r
install.packages("compdb")
```

## Example

Using this package is simple and only requires a call to

``` r
build_compile_commands(path = ".")
```

where `path` should point to the packages base path. It will produce a
file called `compile_commands.json` in the package’s `src/` directory.

## How it works

The package at `path` is built as a source package to a temporary
location. If the package already contains a `Makevars` file, it is
modified at the temporary location to include `PKG_CPPFLAGS += -MJ \@.json`
which will prompt `clang` to generate a compilation database for each
file it processes. If no `Makevars` file exists, a new one is created.
The package is then installed to a temporary location which triggers
compilation of all source files and thereby generates the
compilation databases.

Finally, the compilation databases are merged and the directory of each
file in the compilation database is corrected from the temporary
directory to the actual package directory.

## Inspiration

This package is essentially a re-implementation of the bash script at
[ashiklom/rcpp-cmpdb](https://github.com/ashiklom/rcpp-cmpdb) with
additional bells and whistles.
