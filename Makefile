setup-githooks:
	git lfs install
	git config core.hooksPath .githooks
	git lfs pull
