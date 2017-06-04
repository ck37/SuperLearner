# This file is intended to be run prior to a release, not during
# normal unit testing.

# Based on https://github.com/HenrikBengtsson/future/tree/master/revdep
library(SuperLearner)
library(testthat)
library(devtools)

devtools::revdep_check(bioconductor = T, recursive = T,
             threads = RhpcBLASctl::get_num_cores())

# Save results to the revdep main directory.
devtools::revdep_check_save_summary()

# Print any problems.
devtools::revdep_check_print_problems()
