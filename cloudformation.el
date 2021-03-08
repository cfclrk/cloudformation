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

(defun cloudformation/html-template (contents info)
  "Return complete document string after HTML conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options.

This is just a copy of `org-html-template' with some
modifications."
  (concat
   (when (and (not (org-html-html5-p info)) (org-html-xhtml-p info))
     (let* ((xml-declaration (plist-get info :html-xml-declaration))
	        (decl (or (and (stringp xml-declaration) xml-declaration)
		              (cdr (assoc (plist-get info :html-extension)
				                  xml-declaration))
		              (cdr (assoc "html" xml-declaration))
		              "")))
       (when (not (or (not decl) (string= "" decl)))
	     (format "%s\n"
		         (format decl
			             (or (and org-html-coding-system
				                  (fboundp 'coding-system-get)
				                  (coding-system-get org-html-coding-system 'mime-charset))
			                 "iso-8859-1"))))))
   (org-html-doctype info)
   "\n"
   (concat "<html"
	       (cond ((org-html-xhtml-p info)
		          (format
		           " xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"%s\" xml:lang=\"%s\""
		           (plist-get info :language) (plist-get info :language)))
		         ((org-html-html5-p info)
		          (format " lang=\"%s\"" (plist-get info :language))))
	       ">\n")
   "<head>\n"
   (org-html--build-meta-info info)
   (org-html--build-head info)
   (org-html--build-mathjax-config info)
   "</head>\n"
   "<body>\n"
   (let ((link-up (org-trim (plist-get info :html-link-up)))
	     (link-home (org-trim (plist-get info :html-link-home))))
     (unless (and (string= link-up "") (string= link-home ""))
       (format (plist-get info :html-home/up-format)
	           (or link-up link-home)
	           (or link-home link-up))))
   ;; Preamble.
   (org-html--build-pre/postamble 'preamble info)
   ;; Document contents.
   (let ((div (assq 'content (plist-get info :html-divs))))
     (format "<%s id=\"%s\">\n" (nth 1 div) (nth 2 div)))
   ;; Document title.
   (when (plist-get info :with-title)
     (let ((title (and (plist-get info :with-title)
		               (plist-get info :title)))
	       (subtitle (plist-get info :subtitle))
	       (html5-fancy (org-html--html5-fancy-p info)))
       (when title
	     (format
	      (if html5-fancy
	          "<header>\n<h1 class=\"title\">%s</h1>\n%s</header>"
	        "<h1 class=\"title\">%s%s</h1>\n")
	      (org-export-data title info)
	      (if subtitle
	          (format
	           (if html5-fancy
		           "<p class=\"subtitle\">%s</p>\n"
		         (concat "\n" (org-html-close-tag "br" nil info) "\n"
			             "<span class=\"subtitle\">%s</span>\n"))
	           (org-export-data subtitle info))
	        "")))))
   contents
   (format "</%s>\n" (nth 1 (assq 'content (plist-get info :html-divs))))
   ;; Postamble.
   (org-html--build-pre/postamble 'postamble info)
   ;; Possibly use the Klipse library live code blocks.
   (when (plist-get info :html-klipsify-src)
     (concat "<script>" (plist-get info :html-klipse-selection-script)
	         "</script><script src=\""
	         org-html-klipse-js
	         "\"></script><link rel=\"stylesheet\" type=\"text/css\" href=\""
	         org-html-klipse-css "\"/>"))
   ;; Closing document.
   "</body>\n</html>"))

(org-export-define-derived-backend 'cloudformation-html 'html
  :translate-alist '((template . cloudformation/html-template)))

(defconst cloudformation/org-project-alist
  `(("cloudformation-org"
     :recursive t
	 :base-directory ,(expand-file-name
                       "org" cloudformation/project-directory)
	 :publishing-directory ,(expand-file-name
                             "_org" cloudformation/project-directory)
     :publishing-function org-org-publish-to-org
     :auto-sitemap t
     :sitemap-title "CloudFormation")

    ("cloudformation-html"
     :recursive t
     :base-directory ,(expand-file-name "_org" cloudformation/project-directory)
     :publishing-directory ,(expand-file-name "cloudformation"
                                              site/publishing-directory)
     :publishing-function (org-babel-tangle-publish
						   org-html-publish-to-html)
     :html-head-include-scripts nil
     :html-head-include-default-style nil
     :with-creator nil
     :with-author nil
     :section-numbers nil
     :html-preamble cfclrk/site-preamble
     :html-self-link-headlines t
     :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"/static/main.css\" />")

    ("cloudformation-static"
    :recursive t
    :base-directory ,(expand-file-name "static"
                                       cloudformation/project-directory)
    :publishing-directory ,(expand-file-name "static" site/publishing-directory)
    :base-extension "png\\|jpg\\|gif\\|pdf"
    :publishing-function org-publish-attachment)))

(provide 'cloudformation)
;;; cloudformation.el ends here
