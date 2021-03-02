EMACS=/Users/chris.clark/Projects/emacs/nextstep/Emacs.app/Contents/MacOS/Emacs

.PHONY: cf
cf:
	cask exec emacs -batch -l make.el -f cf

.PHONY: export-org
export-org:
	cask exec ${EMACS} -batch -l make.el -f export-org


.PHONY: tangle-cf
tangle-cf:
	cask exec emacs -batch -l make.el -f tangle-cf

clean:
	rm -rf _org _yaml org/sitemap.org

org-version:
	cask exec emacs -batch -l make.el -f org-version
