#!/usr/bin/Rscript
# ^ support Rscript execution

# This file is intended to be run prior to a release, not during
# normal unit testing.
# To run CI on Travis set env variable SL_CRAN=1 in the web UI,
# then re-build commit.

# Based on https://github.com/HenrikBengtsson/future/tree/master/revdep
# And https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/script/r.rb#L256
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

  # Clear any existing results.
  devtools::revdep_check_reset()

  ignore_packages = NULL

  # If we're on Travis, disable some reverse dependency packages that
  # cause the check to fail.
  if (Sys.getenv("TRAVIS") == "true") {
    # First, disable all packages until we can get it to work.
    #ignore_packages = c("CovSelHigh", "ltmle", "medflex", "simcausal",
    #                    "subsemble", "tmle", "tmle.npvi", "tmlenet")

    # This should be /home/travis/R/library on Travis.
    cat("Using R library:", Sys.getenv("R_LIBS_USER"), "\n")
    # Set revdep.libpath to try to reuse packages we already installed.
    options(devtools.revdep.libpath = Sys.getenv("R_LIBS_USER"))
  }

  # Turn off bioconductor check for now, but enable once this is working.
  # Turn off recursive check for now, but re-enable once this works.
  result = devtools::revdep_check(bioconductor = F, recursive = F,
                                  ignore = ignore_packages,
                                  #threads = RhpcBLASctl::get_num_cores(),
                                  threads = 1,
                                  # Set to F for debugging.
                                  quiet_check = F)

  if (length(result) > 0) {
    # Save results to the revdep main directory.
    devtools::revdep_check_save_summary()

    # Print any problems.
    print(devtools::revdep_check_print_problems())

    # If this script is running inside travis CI, explicitly quit.
    if (Sys.getenv("TRAVIS_R_VERSION") != "") {
      q(status = 1, save = "no");
    }
  } else {
    cat("No reverse dependency problems found. Great job!\n")
  }
} else {
  cat("Skipping revdep.\n")
}
