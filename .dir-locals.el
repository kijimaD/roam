((org-mode . ((eval . (progn
                        (defun kd/denote-format ()
                          "仕上げる。"
                          (interactive)
                          (progn
                            (flush-lines "^\\#\s.+?")
                            (kd/org-remove-comment-block)
                            (kd/org-remove-draft-filetag)
                            (denote-rename-file-using-front-matter (buffer-file-name) 0)
                            ))

                        (defun kd/denote-kdoc-rename ()
                          "自動採番する。"
                          (interactive)
                          (let* ((max 0)
                                 (files (directory-files "." nil ".*--kdoc-\\([0-9].+?\\)$"))
                                 (numbers (mapcar (lambda (name)
                                                    (if (nth 3 (split-string name "-"))
                                                        (setq max (string-to-number (nth 3 (split-string name "-")))))
                                                    ) files)))
                            (save-excursion
                              (beginning-of-buffer)
                              (if (search-forward "KDOC n" nil t)
                                  (replace-match (format "KDOC %d" (+ max 1)))))
                            (denote-rename-file-using-front-matter (buffer-file-name) 0)))

                        (defun kd/org-remove-comment-block ()
                          "コメントブロックを削除する。"
                          (interactive)
                          (save-excursion
                            (goto-char (point-min))
                            (while (re-search-forward "^\\s-*#\\+begin_comment\\s-*$" nil t)
                              (let ((start (match-beginning 0)))
                                (when (re-search-forward "^\\s-*#\\+end_comment\\s-*$" nil t)
                                  (delete-region start (match-end 0))
                                  (when (looking-at "\n")
                                    (delete-char 1)))))))

                        (defun kd/org-remove-draft-filetag ()
                          "ドラフトタグを外す。"
                          (interactive)
                          (save-excursion
                            (goto-char (point-min))
                            (when (re-search-forward "^#\\+filetags:[ \t]*\\(.*\\)" nil t)
                              (let* ((tags (match-string 1))
                                     (new-tags (replace-regexp-in-string ":draft:" ":" tags)))
                                (replace-match new-tags nil nil nil 1)))))
                        (defun kd/ensure-blank-line-before-status ()
                          "「* この文書のステータス」の前に必ず空行を入れる。"
                          (interactive)
                          (save-excursion
                            (goto-char (point-min))
                            (when (re-search-forward "^\\* この文書のステータス" nil t)
                              (beginning-of-line)
                              (unless (looking-back "\n\n" 2)
                                (if (looking-back "\n" 1)
                                    (insert "\n")
                                  (insert "\n\n"))))))
                        )))))
