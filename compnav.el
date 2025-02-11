;;; compnav.el --- Full compnav support for eshell  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Marcin Swieczkowski <marcin@realemail.net>

;; Author: Marcin Swieczkowski <marcin@realemail.net>
;; Maintainer: Marcin Swieczkowski <marcin@realemail.net>
;; URL: https://github.com/mrcnski/compnav-eshell
;; Version: 0.0.1
;; Package-Requires: ((emacs "29.1"))
;; Keywords: convenience

;; This file is NOT part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; TODO

;;; Code:

;; Update .z file.
(defun compnav--add-pwd ()
  ;; Don't use `shell-command' to avoid "(Shell command succeeded with
  ;; no output)" messages.
  (shell-command-to-string "ruby \"$COMPNAV_DIR/z.rb\" --add \"$PWD\""))
(add-hook 'eshell-directory-change-hook 'compnav--add-pwd)
(add-hook 'eshell-mode-hook 'compnav--add-pwd)

;; TODO: implement start-accept.
(defun compnav--select (prompt collection args history reverse &optional start-accept)
  (cond
   ;; Equivalent of fzf's --select-1.
   ((= 1 (length collection))
    (car collection))
   ;; Equivalent of fzf's --exit-0.
   ((= 0 (length collection))
    nil)
   (t
    (when reverse
      (setq collection (reverse collection)))
    (let (
          (initial-input (string-join args " "))
          (def (car collection))
          (minibuffer-completion-confirm nil)
          ;; Fix for vertico sorting the collection. We want matches to be
          ;; displayed in order.
          ;; TODO: use custom selection function
          (vertico-sort-function nil)
          )
      ;; (if start-accept
      ;;     (substring-no-properties
      ;;      (car (completion-all-completions initial-input collection nil nil)))
        ;; `t' for `require-match' means the input must be an element of `collection'.
      (completing-read prompt collection nil t initial-input history def)))))
       ;; )

(defvar compnav-up-history nil)
(defun eshell/up (&rest args)
  "Go up to a parent directory.

ARGS is used as the initial input to filter matches."
  (let* (
         ;; TODO: move command to compnav-select.
         (output (shell-command-to-string "ruby \"$COMPNAV_DIR/up.rb\""))
         (dirs (string-split (string-trim output) "\n" t))
         ;; TODO: Remove this conditional once start-accept works.
         (dir (if (null args)
                  (car dirs)
                (compnav--select "up: " dirs args 'compnav-up-history nil t))))
    (when dir
      (eshell/cd dir))))

(defvar compnav-z-history nil)
(defun eshell/z (&rest args)
  "Jump to a recent directory.

ARGS is used as the initial input to filter matches."
  (let* (
         (output (shell-command-to-string "ruby \"$COMPNAV_DIR/z.rb\""))
         (dirs (string-split (string-trim output) "\n" t))
         (dir (compnav--select "z: " dirs args 'compnav-z-history t)))
    (when dir
      (eshell/cd dir))))

(defvar compnav-h-history nil)
(defun eshell/h (&rest args)
  "Jump to a repo.

ARGS is used as the initial input to filter matches."
  (let* (
         (output (shell-command-to-string "ruby \"$COMPNAV_DIR/h.rb\""))
         (dirs (string-split (string-trim output) "\n" t))
         (dir (compnav--select "h: " dirs args 'compnav-h-history t)))
    (when dir
      (eshell/cd dir))))

(provide 'compnav)
;;; compnav.el ends here
