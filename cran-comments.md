* Initial package release
* Ignore cran-comments.md during build
* This package is unix only and requires clang >= 5.0 to be installed
* It targets users that compile their packages with clang and aborts
  if other compilers are used.
* Added return value and respective documentation to `build_compile_commands`
* Removed reference to LLVM in DESCRIPTION. Note that LLVM is not an acronym,
  but the name of the software project itself
  (third sentence on https://llvm.org/)
* Added quotes around software names in package title and description. Note
  that C/C++ refers to the programming languages and therefore are not
  names of packages, software, or an API.
