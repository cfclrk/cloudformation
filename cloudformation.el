;;; cloudformation.el -- My CloudFormation project  -*- lexical-binding: t; -*-

;;; Commentary:

;; A bunch of AWS CloudFormation templates define in org-mode and tangled to
;; yaml.

;;; Code:

(require 'site)
(require 'ox-html)

(defconst cloudformation/project-directory
  (file-name-directory (or load-file-name buffer-file-name)))

;; Preprocessing Hook
;; -----------------------------

(defun cloudformation/yaml-path (org-path)
  "Return path to yaml file for ORG-PATH."
  (f-swap-ext
   (f-relative org-path
               (f-join cloudformation/project-directory "_org"))
   "yaml"))

(defun cloudformation/is-buffer-cf-template? ()
  "True if the current buffer is for a CF template.
False if current buffer is home page or sitemap."
  (let ((buf (buffer-file-name)))
    (not (or (s-contains? "sitemap" buf)
             (s-contains? "home" buf)))))

(defun cloudformation/add-yaml-link-to-html (backend)
  "Preprocessing function run in `org-export-before-processing-hook'.
BACKEND is the export backend."
  (when (and
         (org-export-derived-backend-p backend 'cloudformation/html)
         (cloudformation/is-buffer-cf-template?))
    (let* ((org-file (buffer-file-name)))
      (save-excursion
        (goto-char (point-min))
        (insert
         (format
          "- CloudFormation template: [[%s][yaml]]\n"
          (format "https://cfclrk.github.io/cloudformation/%s"
                  (cloudformation/yaml-path org-file))))))))

(add-hook
 'org-export-before-processing-hook
 'cloudformation/add-yaml-link-to-html)

;; Derived Backend
;; ---------------------

;; Define a new backend only so that we can run processing hook for this backend
;; but not for others.

(org-export-define-derived-backend 'cloudformation/html 'site/html)

(defun cloudformation/org-html-publish-to-html (plist filename pub-dir)
  "Publish an org file to HTML.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (org-publish-org-to 'cloudformation/html filename
		      (concat (when (> (length org-html-extension) 0) ".")
			      (or (plist-get plist :html-extension)
				  org-html-extension
				  "html"))
		      plist pub-dir))

(defconst cloudformation/org-project-alist

  ;; Generate .org files in the _org directory
  `(("cloudformation-org"
     :recursive t
	 :base-directory
     ,(expand-file-name "org" cloudformation/project-directory)
	 :publishing-directory
     ,(expand-file-name "_org" cloudformation/project-directory)
     :publishing-function org-org-publish-to-org
     :auto-sitemap t
     :sitemap-title "CloudFormation"
     :with-creator nil
     :with-author nil
     :with-timestamps nil)

    ;; Publish org files from the _org directory to the _out directory
    ("cloudformation-out"
     :recursive t
     :base-directory
     ,(expand-file-name "_org" cloudformation/project-directory)
     :publishing-directory
     ,(expand-file-name "_out" cloudformation/project-directory)
     :publishing-function
     (;; Tangle org files to yaml, and put yaml files in target dir
      org-babel-tangle-publish

      ;; Export org files to HTML, and put HTML files in target dir
      cloudformation/org-html-publish-to-html

      ;; Copy each org file to the target dir
      org-publish-attachment)
     :html-head-include-scripts nil
     :html-head-include-default-style nil
     :with-creator nil
     :with-author nil
     :section-numbers nil
     :with-timestamps nil
     :html-preamble site/site-preamble
     :html-self-link-headlines t
     :html-head
     "<link rel=\"stylesheet\" type=\"text/css\" href=\"/static/main.css\" />")

    ;; Copy files to the cfclrk.com project
    ("cloudformation-copy"
     :recursive t
     :base-directory
     ,(expand-file-name "_out" cloudformation/project-directory)
     :publishing-directory
     ,(expand-file-name "cloudformation" site/publishing-directory)
     :base-extension "org\\|yaml\\|html"
     :publishing-function org-publish-attachment)

    ;; Copy images to the cfclrk.com project
    ("cloudformation-img"
     :recursive t
     :base-directory
     ,(expand-file-name "img" cloudformation/project-directory)
     :publishing-directory
     ,(expand-file-name "img" site/publishing-directory)
     :base-extension "png\\|jpg\\|gif\\|pdf"
     :publishing-function org-publish-attachment)))

(provide 'cloudformation)

;;; cloudformation.el ends here
