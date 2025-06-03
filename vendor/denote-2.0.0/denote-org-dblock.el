;;; denote-org-dblock.el --- Org Dynamic blocks for denote.el -*- lexical-binding: t -*-

;; Copyright (C) 2022-2023  Free Software Foundation, Inc.

;; Author: Elias Storms <elias.storms@gmail.com>
;; Maintainer: Denote Development <~protesilaos/denote@lists.sr.ht>
;; URL: https://git.sr.ht/~protesilaos/denote
;; Mailing-List: https://lists.sr.ht/~protesilaos/denote

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This file provides a specialized Org-mode extension to Denote: it
;; introduces Org Dynamic blocks that collect links to Denote notes
;; based on a provided regexp.  In short, this automates
;; 'denote-add-links'.
;;
;; For more information, read the commented code below or refer to the
;; Denote manual

;;; Code:

(require 'denote)
(require 'org)

;;; Org-mode Dynamic blocks

;;;; Dynamic block to search links

;; Org-mode has Dynamic blocks the content of which can be computed
;; dynamically based on their header. This functionality can be
;; leveraged to create automated lists of links to specific notes
;; (similar to 'denote-add-links', but with the added benefit
;; that the list can be updated easily).
;;
;; A dynamic block of the 'denote-links' type looks like this:
;;
;;     #+BEGIN: denote-links :regexp "denote"
;;
;;     #+END:
;;
;; With point at the #+BEGIN: line, pressing 'C-c C-c' will replace the
;; contents of the block with links to notes matching the search
;; ':regexp'. The regular expression can be either a regexp string or
;; a sexp form (the latter is translated via rx).
;; See also the denote manual on 'denote-add-links'.
;;
;; Inserting a block can be done via the Org-mode entry point
;; 'org-dynamic-block-insert-dblock' and selecting 'denote-links' from
;; the list, or directly by calling 'denote-org-dblock-insert-links'.
;;
;;
;; Org Dynamic blocks of the denote-links type can have the follwoing
;; arguments (in any order):
;;  1. :regexp input    -- the search input (required), either as a
;;                         regexp string or a sexp (in rx notation)
;;  2. :missing-only t  -- to only include missing links
;;  3. :reverse t       -- reverse sort order (or don't, when nil)
;;  4. :block-name "n"  -- to include a name for later processing
;;
;; By default ':missing-only t' is included as a parameter in the
;; block's header, so that only "missing links" are included (i.e.,
;; links to notes that the current buffer doesn't already link to).
;; Remove this parameter or set to 'nil' to include all matching
;; notes.
;;
;; With ':reverse' the value of 'denote-link-add-links-sort' can be
;; let-bound specifically for this list of links. For more
;; information, see the documentation of this variable.
;;
;; With ':block-name "string"' include a '#+NAME: string' line in the
;; Dynamic block. This allows use of the Dynamic block output as input
;; for further computation, e.g. in Org source blocks.

;;;###autoload
(defun denote-org-dblock-insert-links (regexp)
  "Create Org dynamic block to insert Denote links matching REGEXP."
  (interactive
    (list
     (read-regexp "Search for notes matching REGEX: " nil 'denote-link--add-links-history)))
  (org-create-dblock (list :name "denote-links"
                           :regexp regexp
                           :missing-only 't))
  (org-update-dblock))

(org-dynamic-block-define "denote-links" 'denote-org-dblock-insert-links)

;; By using the `org-dblock-write:' format, Org-mode knows how to
;; compute the dynamic block. Inner workings of this function copied
;; from `denote-add-links'.
(defun org-dblock-write:denote-links (params)
  "Function to update `denote-links' Org Dynamic blocks.
Used by `org-dblock-update' with PARAMS provided by the dynamic block."
  (let* ((regexp (plist-get params :regexp))
         (rx (if (listp regexp) (macroexpand `(rx ,regexp)) regexp))
         (missing-only (plist-get params :missing-only))
         (block-name (plist-get params :block-name))
         (denote-link-add-links-sort (plist-get params :reverse))
         (current-file (buffer-file-name)))
    (when block-name
      (insert "#+name: " block-name "\n"))
    (if missing-only
        (progn
          (denote-add-missing-links rx)
          (join-line)) ;; remove trailing empty line left by denote-link--prepare-links
      (when-let ((files (delete current-file
                                (denote-directory-files-matching-regexp rx))))
        (insert (denote-link--prepare-links files current-file nil))
        (join-line))))) ;; remove trailing empty line

;;;; Dynamic block for backlinks

;; Similarly, we can create a 'denote-backlinks' block that inserts
;; links to notes that link to the current note.

;; This block type takes the following parameters:
;;  1. :reverse t       -- reverse sort order (or don't, when nil)

;;;###autoload
(defun denote-org-dblock-insert-backlinks ()
  "Insert new Org dynamic block to include backlinks."
  (interactive)
  (org-create-dblock (list :name "denote-backlinks"))
  (org-update-dblock))

(org-dynamic-block-define "denote-backlinks" 'denote-org-dblock-insert-backlinks)

(defun org-dblock-write:denote-backlinks (params)
  "Function to update `denote-backlinks' Org Dynamic blocks.
Used by `org-dblock-update' with PARAMS provided by the dynamic block."
  (when-let* ((file (buffer-file-name))
              (id (denote-retrieve-filename-identifier file))
              (files (delete file (denote--retrieve-files-in-xrefs id))))
    (let ((denote-link-add-links-sort (plist-get params :reverse)))
      (insert (denote-link--prepare-links files file nil))
      (join-line)))) ;; remove trailing empty line

(provide 'denote-org-dblock)
;;; denote-org-dblock.el ends here
