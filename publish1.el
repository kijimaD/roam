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
      `(div (div (@ (class "blog-header"))
                 (div (@ (class "container"))
                      (div (@ (class "row align-items-center justify-content-between"))
                           (div (@ (class "col-sm col-md"))
                                (div (@ (class "blog-description text-sm-left text-md-right text-lg-right text-xl-right"))
                                     ,dw/site-tagline)))))

            (div (@ (class "blog-masthead"))
                 (div (@ (class "container"))
                      (div (@ (class "row align-items-center justify-content-between"))
                           (div (@ (class "col-sm-12 col-md-12"))
                                (nav (@ (class "nav"))
                                     (a (@ (class "nav-link") (href "/roam")) "Insomnia") " "
                                     (a (@ (class "nav-link") (href "https://github.com/kijimaD")) "kijimad")))))))))))

(defun dw/site-footer (info)
  (concat
   ;; "</div></div>"
   (sxml-to-xml
    `(footer (@ (class "blog-footer"))
      (div (@ (class "container"))
           (div (@ (class "row"))
                (div (@ (class "col-sm col-md text-sm-left text-md-right text-lg-right text-xl-right"))
                     (p "Made with " ,(plist-get info :creator)))))))
   (sxml-to-xml
    `(script (@ (src "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"))))))

(defun get-article-output-path (org-file pub-dir)
  (let ((article-dir (concat pub-dir
                             (downcase
                              (file-name-as-directory
                               (file-name-sans-extension
                                (file-name-nondirectory org-file)))))))

    (if (string-match "\\/index.org$" org-file)
        pub-dir
        (progn
          (unless (file-directory-p article-dir)
            (make-directory article-dir t))
          article-dir))))

(defun dw/org-html-template (contents info)
  (concat
   "<!DOCTYPE html>"
   (sxml-to-xml
    `(html (@ (lang "en"))
           (head
            "<!-- " ,(org-export-data (org-export-get-date info "%Y-%m-%d") info) " -->"
            (meta (@ (charset "utf-8")))
            (meta (@ (author "Kijima Daigo")))
            (meta (@ (name "viewport")
                     (content "width=device-width, initial-scale=1, shrink-to-fit=no")))
            (link (@ (rel "stylesheet")
                     (href "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css")))
            (link (@ (rel "stylesheet")
                     (href "/css/code.css")))
            (link (@ (rel "stylesheet")
                     (href "/css/site.css")))
            (title ,(concat (org-export-data (plist-get info :title) info) " - Insomnia")))
           (body
             ,(dw/site-header info)
             (div (@ (class "container"))
                  (div (@ (class "row justify-content-center"))
                       (div (@ (class "col-sm-8 blog-main"))
                            (div (@ (class "blog-post"))
                                 (h1 (@ (class "blog-post-title"))
                                     ,(org-export-data (plist-get info :title) info))
                                 (p (@ (class "blog-post-meta"))
                                    ,(org-export-data (org-export-get-date info "%B %e, %Y") info))
                                 ,contents
                                 ,(let ((tags (plist-get info :filetags)))
                                    (when (and tags (> (length tags) 0))
                                      `(p (@ (class "blog-post-tags"))
                                          "Tags: "
                                          ,(mapconcat (lambda (tag) tag)
                                                        ;; TODO: We don't have tag pages yet
                                                        ;; (format "<a href=\"/tags/%s/\">%s</a>" tag tag))
                                                      (plist-get info :filetags)
                                                      ", "))))
                                 ,(when (equal "article" (plist-get info :page-type)))))))

             ,(dw/site-footer info))))))

;; Thanks Ashraz!
(defun dw/org-html-link (link contents info)
  "Removes file extension and changes the path into lowercase file:// links."
  (when (string= 'file (org-element-property :type link))
    (org-element-put-property link :path
                              (downcase
                               (file-name-sans-extension
                                (org-element-property :path link)))))

  (let ((exported-link (org-export-custom-protocol-maybe link contents 'html info)))
    (cond
     (exported-link exported-link)
     ((equal contents nil)
      (format "<a href=\"%s\">%s</a>"
              (org-element-property :raw-link link)
              (org-element-property :raw-link link)))
     (t (org-export-with-backend 'slimhtml link contents info)))))

;; Make sure we have thread-last
(require 'subr-x)

(defun dw/make-heading-anchor-name (headline-text)
  (thread-last headline-text
    (downcase)
    (replace-regexp-in-string " " "-")
    (replace-regexp-in-string "[^[:alnum:]_-]" "")))

(defun dw/org-html-headline (headline contents info)
  (let* ((text (org-export-data (org-element-property :title headline) info))
         (level (org-export-get-relative-level headline info))
         (level (min 7 (when level (1+ level))))
         (anchor-name (dw/make-heading-anchor-name text))
         (attributes (org-element-property :ATTR_HTML headline))
         (container (org-element-property :HTML_CONTAINER headline))
         (container-class (and container (org-element-property :HTML_CONTAINER_CLASS headline))))
    (when attributes
      (setq attributes
            (format " %s" (org-html--make-attribute-string
                           (org-export-read-attribute 'attr_html `(nil
                                                                   (attr_html ,(split-string attributes))))))))
    (concat
     (when (and container (not (string= "" container)))
       (format "<%s%s>" container (if container-class (format " class=\"%s\"" container-class) "")))
     (if (not (org-export-low-level-p headline info))
         (format "<h%d%s><a id=\"%s\" class=\"anchor\" href=\"#%s\"></a>%s</h%d>%s"
                 level
                 (or attributes "")
                 anchor-name
                 anchor-name
                 text
                 level
                 (or contents ""))
       (concat
        (when (org-export-first-sibling-p headline info) "<ul>")
        (format "<li>%s%s</li>" text (or contents ""))
        (when (org-export-last-sibling-p headline info) "</ul>")))
     (when (and container (not (string= "" container)))
       (format "</%s>" (cl-subseq container 0 (cl-search " " container)))))))

(org-export-define-derived-backend 'site-html
    'slimhtml
  :translate-alist
  '((template . dw/org-html-template)
    (link . dw/org-html-link)
    (code . ox-slimhtml-verbatim)
    (headline . dw/org-html-headline))
  :options-alist
  '((:page-type "PAGE-TYPE" nil nil t)
    (:html-use-infojs nil nil nil)))

;; (defun org-html-publish-to-html (plist filename pub-dir)
;;   "Publish an org file to HTML, using the FILENAME as the output directory."
;;   (let ((article-path (get-article-output-path filename pub-dir)))
;;     (cl-letf (((symbol-function 'org-export-output-file-name)
;;                (lambda (extension &optional subtreep pub-dir)
;;                  (concat article-path "index" extension))))
;;       (org-publish-org-to 'site-html
;;                           filename
;;                           (concat "." (or (plist-get plist :html-extension)
;;                                           "html"))
;;                           plist
;;                           article-path))))

(defun org-html-publish-to-html (plist filename pub-dir)
  (org-publish-org-to 'html filename
		      (concat (when (> (length org-html-extension) 0) ".")
			      (or (plist-get plist :html-extension)
				  org-html-extension
				  "html"))
		      plist pub-dir))


(setq org-html-preamble  #'dw/site-header
      org-html-postamble #'dw/site-footer
      org-html-metadata-timestamp-format "%Y-%m-%d"
      org-html-checkbox-type 'site-html
      org-html-html5-fancy nil
      org-html-htmlize-output-type 'css
      org-html-self-link-headlines t
      org-html-validation-link nil
      org-html-doctype "html5")

;; Compile
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
