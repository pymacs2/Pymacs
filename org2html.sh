#!/bin/sh
":"; exec emacs --script "$0" -- "$@" # -*-emacs-lisp-*-
;;
;; Usage:
;;    org2html FILE1 [FILE2 ...]

(require 'org)

;; Mark org-related variables as safe local variables,
;; regardless of their value.
(defun my/always-safe-local-variable (val) t)
(dolist (sym '(org-export-publishing-directory
               org-export-html-preamble
               org-export-html-postamble))
  (put sym 'safe-local-variable 'my/always-safe-local-variable))


(defun my/org-export-as-html (filename)
  "Export FILENAME as html, as if `org-export-to-html' had been called
interactively.
This ensures that `org-export-headline-levels' is correctly read from
the #+OPTIONS: headline."
  (save-excursion
    (find-file filename)
    (message "Exporting file `%s' to HTML" filename)
    (call-interactively 'org-html-export-as-html)))

(mapcar 'my/org-export-as-html
        (cdr argv)) ;; "--" is the first element of argv
