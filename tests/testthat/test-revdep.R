# This file is intended to be run prior to a release, not during
# normal unit testing.

# Based on https://github.com/HenrikBengtsson/future/tree/master/revdep
library(SuperLearner)
library(testthat)
library(devtools)

context("Reverse dependency checking")

# Run manually or if SL_CRAN environmental variable is set.
# and we're not in a pull request build.
# This would be done as prep for a CRAN release.
if (Sys.getenv("SL_CRAN") == "true" &&
    Sys.getenv("TRAVIS_PULL_REQUEST") %in% c("", "false") &&
    Sys.getenv("APPVEYOR_PULL_REQUEST_NUMBER") == "") {

  devtools::revdep_check(bioconductor = T, recursive = T,
             threads = RhpcBLASctl::get_num_cores())

  # Save results to the revdep main directory.
  devtools::revdep_check_save_summary()

  # Print any problems.
  print(devtools::revdep_check_print_problems())
} else {
  cat("Skipping revdep.\n")
}
