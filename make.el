;;; make.el --- Functions for building this project  -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'ox-publish)

(setq make-backup-files nil
      org-src-preserve-indentation t)

(setq org-publish-project-alist
      '(("export-org"
         :recursive t
         :base-directory "~/Projects/cloudformation/org/"
         :publishing-directory "~/Projects/cloudformation/exported_org/"
         :publishing-function org-org-publish-to-org)

        ("tangle-cf"
         :recursive t
         :base-directory "~/Projects/cloudformation/exported_org/"
         :publishing-directory "~/Projects/cloudformation/tangled_cf/"
         :publishing-function org-babel-tangle-publish)

        ("cf"
         :components ("export-org" "tangle-cf"))))


(defun export-org ()
  "Export org files to org to process INCLUDE statements."
  (org-publish "export-org"))


(defun tangle-cf ()
  "Tangle org files into CloudFormation."
  (org-publish "tangle-cf"))


(defun cf ()
  "Run it all."
  (org-publish "cf"))


(defun print-version ()
  "Just print the org mode version for debugging purposes."
  (message org-version))

;;; make.el end here
