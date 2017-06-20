# Run CRAN-specific tests.
cran:
	Rscript tests/cran/revdep.R

clean:
	rm -rf revdep revdep.Rout