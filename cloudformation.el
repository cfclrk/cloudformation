;;; cloudformation.el -- My notes  -*- lexical-binding: t; -*-

;;; Commentary:

;; A bunch of AWS CloudFormation templates define in org-mode and tangled to
;; yaml. An HTML version is available online at
;; https://cfclrk.com/cloudformation.

;;; Code:

(require 'site)
(require 'ox-html)

(defconst cloudformation/project-directory
  (file-name-directory (or load-file-name buffer-file-name)))

(defconst cloudformation/org-project-cloudformation
  `("cloudformation-org"
    :recursive t
	:base-directory ,cloudformation/project-directory
	:publishing-directory ,(expand-file-name "_org"
                                             cloudformation/project-directory)
    :publishing-function org-org-publish-to-org
	:auto-sitemap t
	:sitemap-title "CloudFormation"))

(defconst cloudformation/org-project-html
  `("cloudformation-html"
    :recursive t
    :base-directory ,(expand-file-name "_org" cloudformation/project-directory)
    :publishing-directory ,(expand-file-name "cloudformation"
                                             site/publishing-directory)
    :publishing-function (org-babel-tangle-publish
						  org-html-publish-to-html)
    :exclude "params\\.org"
    :auto-sitemap t
    :html-head-include-scripts nil
    :html-head-include-default-style nil
    :with-creator nil
    :with-author nil
    :section-numbers nil
    :html-preamble cfclrk/site-preamble
    :html-self-link-headlines t
    :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"/static/main.css\" />"))

(defconst cloudformation/org-project-static
  `("cf-static"
    :recursive t
    :base-directory ,(expand-file-name "static"
                                       cloudformation/project-directory)
    :publishing-directory ,(expand-file-name "static" site/publishing-directory)
    :base-extension "png\\|jpg\\|gif\\|pdf"
    :publishing-function org-publish-attachment))

(provide 'cloudformation)
;;; cloudformation.el ends here
