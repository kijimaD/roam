;; Initialize package sources
(require 'package)

;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(setq package-user-dir (expand-file-name "./.packages"))

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

(use-package org-roam
  :ensure t)
(setq org-roam-directory ".")
(setq org-roam-v2-ack t)
(setq org-id-link-to-org-use-id t)
(setq org-id-extra-files (org-roam--list-files org-roam-directory))

(use-package ox-hugo
  :ensure t)
(setq org-hugo-base-dir ".")

;;; Code:
(setq org-publish-project-alist
      (list
       (list "kijima:roam"
             :recursive t
             :base-extension "org"
             :base-directory "./"
             :publishing-function #'org-html-publish-to-html
             :publishing-directory "./public"
             :with-timestamps nil
             :with-title nil)))

(defun kd/publish ()
  (org-publish-all t))

(provide 'publish)
