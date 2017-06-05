# This file is intended to be run prior to a release, not during
# normal unit testing.
# To run CI on Travis set env variable R_CHECK_REVDEP=1 in the web UI,
# then re-build commit.

# Based on https://github.com/HenrikBengtsson/future/tree/master/revdep
library(SuperLearner)
library(devtools)

# Run manually or if SL_CRAN environmental variable is set and we're not in a
# pull request build.
# This would be done as prep for a CRAN release.
# This is not currently working on our CI systems: Travis and Appveyor.
if (Sys.getenv("SL_CRAN") == "true" &&
    Sys.getenv("TRAVIS_PULL_REQUEST") %in% c("", "false") &&
    Sys.getenv("APPVEYOR_PULL_REQUEST_NUMBER") == "") {

  cat("Checking reverse dependencies.\n")

  if (!requireNamespace("BiocInstaller", quietly = T)) {
    # Manually re-install bioc, unclear why this is necessary on Appveyor.
    source('https://bioconductor.org/biocLite.R')
    # This will install BiocInstaller.
    biocLite()
  }

  print(sessionInfo())

  devtools::revdep_check(bioconductor = T, recursive = T,
             threads = RhpcBLASctl::get_num_cores())

  # Save results to the revdep main directory.
  devtools::revdep_check_save_summary()

  # Print any problems.
  print(devtools::revdep_check_print_problems())
} else {
  cat("Skipping revdep.\n")
}
