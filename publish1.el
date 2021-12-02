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

;; Unfortunately this is necessary for now...
(load-file "./ox-slimhtml.el")

;; Install other dependencies
(use-package esxml
  :ensure t)

(use-package org-roam
  :ensure t)
(setq org-roam-directory "./")
(setq org-roam-v2-ack t)
(setq org-id-link-to-org-use-id t)
(setq org-id-extra-files (org-roam--list-files org-roam-directory))

(use-package htmlize
  :ensure t)

(require 'ox-publish)

(setq make-backup-files nil)
(setq org-export-with-smart-quotes t)

;; View
(setq dw/site-title   "Insomnia")
(setq dw/site-tagline "")

(setq org-publish-use-timestamps-flag t
      org-publish-timestamp-directory "./.org-cache/"
      org-export-with-section-numbers nil
      org-export-use-babel nil
      org-export-with-smart-quotes t
      org-export-with-sub-superscripts nil
      org-export-with-tags 'not-in-toc
      org-export-with-toc t)

(defun dw/site-header (info)
  (let* ((file (plist-get info :output-file)))
    (concat
     (sxml-to-xml
      `(div (div (@ (class "header"))
                 (div (@ (class "container"))
                      (div (@ (class "row"))
                           (div (@ (class "col-sm-12 col-md-12"))
                                (nav (@ (class "navbar navbar-light"))
                                     ;; (a (@ (class "nav-link text-dark") (href "/roam")) "Insomnia")
                                     ))))))))))

(defun dw/site-footer (info)
  (concat
   ;; "</div></div>"
   (sxml-to-xml
    `(footer (@ (class "footer py-3"))
      (div (@ (class "container"))
           (div (@ (class "row "))
                (div (@ (class "col-md-4")) "")
                (div (@ (class "col-sm col-md"))
                     (nav (@ (class "navbar"))
                          (a (@ (class "nav-link text-secondary small") (href "/roam")) "Insomnia")
                          (a (@ (class "nav-link text-secondary small") (href "./sitemap.html")) "Sitemap")
                          (a (@ (class "nav-link text-secondary small") (href "https://github.com/kijimaD/roam")) "Repository")
                          (a (@ (class "nav-link text-secondary small") (href "https://github.com/kijimaD")) "@kijimaD")))
                (div (@ (class "col-md-4")) "")))))
   (sxml-to-xml
    `(script (@ (src "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"))))))

(setq org-html-preamble  #'dw/site-header
      org-html-postamble #'dw/site-footer
      org-html-metadata-timestamp-format "%Y-%m-%d"
      org-html-html5-fancy nil
      org-html-htmlize-output-type 'css
      org-html-self-link-headlines t
      org-html-validation-link nil
      org-html-doctype "html5")

(setq my-blog-extra-head
      (concat
       "<link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css' />"
       "<link rel='stylesheet' href='css/site.css' />"
       "<link rel='stylesheet' href='css/code.css' />"))

;; Compile
(setq org-publish-project-alist
  `(
     ("kijima:roam"
      :recursive t
      :base-extension "org"
      :base-directory "./"
      ;; :publishing-function #'org-html-publish-to-html
      :publishing-function org-html-publish-to-html
      :publishing-directory "./public"

      :html-link-home "/"
      :html-head nil ;; cleans up anything that would have been in there.
      :html-head-extra ,my-blog-extra-head
      :html-head-include-default-style nil
      :html-head-include-scripts nil

      :html-link-up ""
      :html-link-home ""
      :with-timestamps nil
      :with-toc nil

      :sitemap-title "Sitemap"
      :auto-sitemap t ; generate sitemap.org automagically
      )))

(defun org-roam-graph-save ()
  (interactive)
  (setq org-roam-graph-viewer nil)
  (setq org-roam-graph-link-hidden-types '("https" "http" "file"))
  (org-roam-db-autosync-mode)
  (org-roam-graph)
  (sleep-for 2)
  (shell-command (concat "mv"
                         " "
                         (nth 0 (file-expand-wildcards "/tmp/graph.*.svg"))
                         " "
                         "./public/graph.svg"))
  (shell-command "rm /tmp/*.dot"))

(setq org-todo-keywords '((type "TODO" "WAIT" "|" "DONE" "CLOSE")))
(setq org-todo-keyword-faces
      '(("TODO" . (:foreground "orange" :weight bold))
        ("WAIT" . (:foreground "HotPink2" :weight bold))
        ("DONE" . (:foreground "green" :weight bold))
        ("CLOSE" . (:foreground "DarkOrchid" :weight bold))))

(setq org-agenda-exporter-settings
      '((ps-number-of-columns 2)
        (ps-landscape-mode t)
        (org-agenda-add-entry-text-maxlines 0)
        (org-agenda-show-log nil)
        (org-agenda-with-colors t)
        (org-agenda-remove-tags t)
        (htmlize-output-type 'inline-css)))

(setq org-agenda-custom-commands
      '(("X" agenda ""
         ((org-agenda-span 7)
          (org-agenda-start-day "-7d")
          (org-agenda-start-with-log-mode t)
          (org-agenda-files '("./")))
         ("./public/agenda.html"))))

(setq org-agenda-prefix-format
      `((agenda . " %i %-12(vulpea-agenda-category)%?-12t% s")
        (todo . " %i %-12(vulpea-agenda-category) ")
        (tags . " %i %-12(vulpea-agenda-category) ")
        (search . " %i %-12(vaulpea-agenda-category) ")))

;; original -> https://d12frosted.io/posts/2020-06-24-task-management-with-roam-vol2.html
(defun vulpea-agenda-category ()
  (let* ((title (vulpea-buffer-prop-get "title")))
    title))

(defun vulpea-buffer-prop-get (name)
  "Get a buffer property called NAME as a string."
  (org-with-point-at 1
    (if (re-search-forward (concat "^#\\+" name ": \\(.*\\)")
                             (point-max) t)
        (buffer-substring-no-properties
         (match-beginning 1)
         (match-end 1))
      "")))

(defun kd/update-index-table ()
  "update index.org table"
  (let ((org-agenda-files '("./")))
    (find-file "index.org")
    (org-dblock-update t)
    (save-buffer)))

(defun kd/publish ()
  (org-publish-all t)
  (org-agenda nil "X")
  (org-batch-store-agenda-views))

(provide 'publish)
