;;; cloudformation.el -- My CloudFormation project  -*- lexical-binding: t; -*-

;;; Commentary:

;; A bunch of AWS CloudFormation templates define in org-mode and tangled to
;; yaml. An HTML version is available online at
;; https://cfclrk.com/cloudformation.

;;; Code:

(require 'site)
(require 'ox-html)

(defconst cloudformation/project-directory
  (file-name-directory (or load-file-name buffer-file-name)))

(org-export-define-derived-backend 'cloudformation-html 'html
  :translate-alist '((template . cloudformation/html-template)))

(defconst cloudformation/org-project-alist

  ;; Generate .org files in the _org directory
  `(("cloudformation-org"
     :recursive t
	 :base-directory ,(expand-file-name
                       "org" cloudformation/project-directory)
	 :publishing-directory ,(expand-file-name
                             "_org" cloudformation/project-directory)
     :publishing-function org-org-publish-to-org
     :auto-sitemap t
     :sitemap-title "CloudFormation")

    ;; Publish generated .org files to the _out directory
    ("cloudformation-out"
     :recursive t
     :base-directory ,(expand-file-name "_org" cloudformation/project-directory)
     :publishing-directory ,(expand-file-name "_out"
                                              cloudformation/project-directory)
     :publishing-function (org-babel-tangle-publish
						   org-html-publish-to-html
                           org-publish-attachment)
     :html-head-include-scripts nil
     :html-head-include-default-style nil
     :with-creator nil
     :with-author nil
     :section-numbers nil
     :html-preamble cfclrk/site-preamble
     :html-self-link-headlines t
     :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"/static/main.css\" />")

    ;; Copy files to the cfclrk.com project
    ("cloudformation-copy"
     :recursive t
     :base-directory ,(expand-file-name "_out"
                                        cloudformation/project-directory)
     :publishing-directory ,(expand-file-name "cloudformation" site/publishing-directory)
     :base-extension "org\\|yaml\\|html"
     :publishing-function org-publish-attachment)

    ;; Copy images to the cfclrk.com project
    ("cloudformation-img"
     :recursive t
     :base-directory ,(expand-file-name "img"
                                        cloudformation/project-directory)
     :publishing-directory ,(expand-file-name "static/img" site/publishing-directory)
     :base-extension "png\\|jpg\\|gif\\|pdf"
     :publishing-function org-publish-attachment)))

(provide 'cloudformation)
;;; cloudformation.el ends here
