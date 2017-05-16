.PHONY: inv help Makefile

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
AUTOBUILD     = sphinx-autobuild
SPHINXPROJ    = DatapuntBGT
SOURCEDIR     = .
BUILDDIR      = _build


# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)


inv: sphinx.inv python.inv


# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)


server:
	@$(AUTOBUILD) "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) --watch ../src


sphinx.inv:
	{ printf "\x1f\x8b\x08\x00\x00\x00\x00\x00"; \
	  curl --silent 'http://www.sphinx-doc.org/en/stable/objects.inv' | tail -n +5; \
	  } | gunzip --quiet >'sphinx.inv' || true


python.inv:
	{ printf "\x1f\x8b\x08\x00\x00\x00\x00\x00"; \
	  curl --silent 'https://docs.python.org/3.6/objects.inv' | tail -n +5; \
	  } | gunzip --quiet >'python.inv' || true
