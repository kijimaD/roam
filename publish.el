;; Initialize package sources
(require 'package)

(defun yes-or-no-p (dummy) t)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(setq package-user-dir (expand-file-name "./.packages"))

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")))

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

(use-package emacsql-sqlite
  :ensure t)

;; Install other dependencies
(use-package esxml
  :ensure t)

;; denote v2.0.0
(use-package denote
  :ensure t
  :straight (:host github :repo "protesilaos/denote")
  :custom ((denote-directory "./")
           (denote-file-type 'org)))
(require 'denote-org-dblock)

(use-package org-roam
  :ensure t)
(setq org-roam-directory "./")
(setq org-roam-db-location "./org-roam.db")
(setq org-roam-v2-ack t)
(setq org-id-link-to-org-use-id t)
(setq org-id-extra-files (org-roam--list-files org-roam-directory))

(use-package htmlize
  :ensure t)

(require 'ox-publish)

(setq make-backup-files nil)
(setq org-export-with-smart-quotes t)
(setq org-html-checkbox-type 'html)
(setq org-babel-default-header-args '((:session . "none") (:results . "replace") (:exports . "code") (:cache . "no") (:noweb . "no") (:hlines . "no") (:tangle . "no")(:wrap . "src")))
;; CIでNo org-babel-execute function for bash!と出るので
(org-babel-do-load-languages 'org-babel-load-languages
                             '((shell . t)
                               ))

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
      org-export-with-toc nil)

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
                          (a (@ (class "nav-link text-secondary small px-0") (href "./index.html")) "Insomnia")
                          (a (@ (class "nav-link text-secondary small px-0") (href "./sitemap.html")) "Sitemap")
                          (a (@ (class "nav-link text-secondary small px-0") (href "https://github.com/kijimaD/roam")) "Repository")
                          (a (@ (class "nav-link text-secondary small px-0") (href "https://github.com/kijimaD")) "@kijimaD")))
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
       ;; ブラウザは、そのサイトのホスト直下に favicon.ico が 設置されていることを期待する。
       ;; GitHub Pagesにデプロイすると、ベースURLがプロジェクト下になるのでホスト直下にfaviconが配置されていないことになる。
       ;; なので明示的に指定してやる。
       "<link rel='shortcut icon' type='image/x-icon' href='/roam/favicon.ico' />"

       "<link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css' />"
       "<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css' />"

       ;; ルートディレクトリにないorgファイルをエクスポートした場合、相対パスが変わる。絶対パスにするとGH pagesのルートディレクトリがpublicの一つ上の階層になる(/リポジトリ名/public)ため、ローカル環境で使えなくなる。つまりローカルでは`/`でokなのに、本番では`/roam`としないといけない。仕方ないので両方読み込む
       "<link rel='stylesheet' href='../css/site.css' />"
       "<link rel='stylesheet' href='../roam/css/code.css' />"
       "<link rel='stylesheet' href='css/site.css' />"
       "<link rel='stylesheet' href='css/code.css' />"
       ))

;; Compile
(setq org-publish-project-alist
  `(
     ("kijima:roam"
      :recursive t
      :base-extension "org"
      :base-directory "./"
      :exclude "NEWS.org"               ;; FIXME: can't specify .packages directory...
      ;; :publishing-function #'org-html-publish-to-html
      :publishing-function org-html-publish-to-html
      :publishing-directory "./public"

      :html-link-home "/"
      :html-head nil  ;; cleans up anything that would have been in there.
      :html-head-extra ,my-blog-extra-head
      :html-head-include-default-style nil
      :html-head-include-scripts nil

      :html-link-up ""
      :html-link-home ""
      :with-timestamps nil
      :with-toc nil

      :sitemap-title "Sitemap"
      :auto-sitemap t             ;; generate sitemap.org automatically
      )))

(defun generate-org-roam-db ()
  (interactive)
  (setq org-roam-graph-viewer nil)
  (setq org-roam-graph-link-hidden-types '("https" "http" "file"))
  (setq org-roam-v2-ack t)
  (org-roam-db-sync))

(setq org-todo-keywords '((type "TODO" "WIP" "|" "DONE" "CLOSE")))
(setq org-todo-keyword-faces
      '(("TODO" . (:foreground "orange" :weight bold))
        ("WIP" . (:foreground "DeepSkyBlue" :weight bold))
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
      '(("Future" agenda ""
         ((org-agenda-span 60)
          (org-agenda-start-day "0d")
          (org-agenda-start-with-log-mode t)
          (org-agenda-tag-filter-preset '("-Habit"))
          (org-agenda-files '("./")))
         ("./public/future-agenda.html"))
        ("Past" agenda ""
         ((org-agenda-span 365)
          (org-agenda-start-day "-365d")
          (org-agenda-start-with-log-mode t)
          (org-agenda-tag-filter-preset '("-Habit"))
          (org-agenda-files '("./")))
         ("./public/past-agenda.html"))))

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
    (org-babel-execute-buffer)
    (save-buffer)))

(defun kd/update-dlinks-table ()
  "update kdoc.org table"
  (let ((org-agenda-files '("./")))
    (find-file "dlinks.org")
    (org-dblock-update t)
    (org-babel-execute-buffer)
    (save-buffer)))

(defun kd/publish ()
  (org-publish-all t)
  ;; (org-agenda nil "Future") ;; test
  ;; (org-agenda nil "Past") ;; test
  (org-batch-store-agenda-views))

(provide 'publish)
