;;; consult-nix-search-tv.el --- consult interface for nix-search-tv  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  ril

;; Author: ril <fenril.nh@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "30.1") (consult "3.0"))
;; Keywords: convenience
;; URL: https://github.com/fenril058/consult-nix-search-tv
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Consult integration for nix-search-tv.

;;; Code:

(require 'consult)
(require 'ansi-color)

(defgroup consult-nix-search-tv nil
  "Consult integration for nix-search-tv."
  :group 'convenience)

(defcustom consult-nix-search-tv-preview-buffer
  "*nix-search-tv-preview*"
  "Preview buffer name."
  :type 'string
  :group 'consult-nix-search-tv)

(defun consult-nix-search-tv--command (command candidate)
  "Run nix-search-tv COMMAND against CANDIDATE."
  (ansi-color-filter-apply
   (shell-command-to-string
    (format
     "nix-search-tv %s %s"
     command
     (shell-quote-argument candidate)))))

(defun consult-nix-search-tv--candidates ()
  "Return nix-search-tv candidates."
  (split-string
   (shell-command-to-string "nix-search-tv print")
   "\n"
   t))

(defun consult-nix-search-tv--preview (candidate)
  "Return preview text for CANDIDATE."
  (consult-nix-search-tv--command "preview" candidate))

(defun consult-nix-search-tv--preview-state ()
  "Create preview state function."
  (lambda (action cand)
    (when (and cand (eq action 'preview))
      (let ((buffer
             (get-buffer-create
              consult-nix-search-tv-preview-buffer)))
        (with-current-buffer buffer
          (let ((inhibit-read-only t))
            (erase-buffer)
            (insert
             (consult-nix-search-tv--preview cand))
            (goto-char (point-min))
            (view-mode 1)))
        (display-buffer buffer)))))

;;;###autoload
(defun consult-nix-search-tv ()
  "Search nix packages using consult."
  (interactive)
  (consult--read
   (consult-nix-search-tv--candidates)
   :prompt "NSTV: "
   :category 'nix-package
   :require-match t
   :sort nil
   :state (consult-nix-search-tv--preview-state)))

(provide 'consult-nix-search-tv)
;;; consult-nix-search-tv.el ends here
