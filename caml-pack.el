;;; caml-pack.el --- Caml

;; Copyright (C) 2013-2018  Antoine R. Dumont (@ardumont)
;; Author: Antoine R. Dumont (@ardumont) <antoine.romain.dumont@gmail.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(defun caml-pack/command-installed-p! (package)
  "Determine if PACKAGE is installed on the machine."
  (zerop (shell-command (format "export PATH=~/.opam/system/bin/:$PATH; which %s" package))))

(defun caml-pack/opam-installed-p! ()
  "Determine if cabal is installed on the machine or not."
  (caml-pack/command-installed-p! "opam"))

(defun caml-pack/install-ml-package (ml-package)
  "Install ML-PACKAGE if needs be and if possible."
  (lexical-let ((package ml-package))
    (when (and (caml-pack/opam-installed-p!) (not (caml-pack/command-installed-p! ml-package)))
      (deferred:$
        (deferred:process "opam" "install" package)
        (deferred:nextc it
          (lambda (x)
            (message "Package '%s' is%s installed!" package
                     (if (or (caml-pack/command-installed-p! package)
                             (caml-pack/command-installed-p! (format "ocaml%s" package)))
                         ""
                       " still not"))))))))

(defun caml-pack/install-ml-packages (packages)
  "Trigger cabal install of PACKAGES."
  (mapc 'caml-pack/install-ml-package packages))

(use-package smartscan)

(use-package tuareg
  :config
  (defun switch-to-caml-buffer ()
    "Switch to the caml buffer if needed."
    (interactive)
    ;; will trigger a caml buffer if needed
    (tuareg-run-process-if-needed)
    (pop-to-buffer tuareg-interactive-buffer-name))

  (bind-key "C-c C-z" 'switch-to-caml-buffer tuareg-mode-map)
  (bind-key "C-c C-l" 'tuareg-eval-buffer    tuareg-mode-map)
  (add-hook 'tuareg-mode-hook 'smartscan-mode)
  (custom-set-variables
   ;; multi line comments
   '(tuareg-comment-end-extra-indent 1)
   ;; make the interactive buffer scroll if needed
   '(tuareg-interactive-scroll-to-bottom-on-output t)))

;; install system deps
(caml-pack/install-ml-packages '("merlin" "ocp-indent"))

;; Add opam emacs directory to the load-path
(defconst opam-share (substring (shell-command-to-string "opam config var share 2> /dev/null") 0 -1))
(add-to-list 'load-path (concat opam-share "/emacs/site-lisp"))
;; enable company for merlin
(require 'company)
;; Load merlin-mode
(require 'merlin)
;; Start merlin on ocaml files
(add-hook 'tuareg-mode-hook 'merlin-mode t)
(add-hook 'caml-mode-hook 'merlin-mode t)
;; Use opam switch to lookup ocamlmerlin binary
(setq merlin-command 'opam)

(defun bury-compile-buffer-if-successful (buffer string)
  "Bury compilation BUFFER if succeeded with finished STRING message."
  (if (and
       (string-match "compilation" (buffer-name buffer))
       (string-match "finished" string)
       (not
        (with-current-buffer buffer
          (search-forward "warning" nil t))))
      (run-with-timer 1 nil
                      (lambda (buf)
                        (bury-buffer buf)
                        (switch-to-prev-buffer (get-buffer-window buf) 'kill))
                      buffer)))
(add-hook 'compilation-finish-functions 'bury-compile-buffer-if-successful)

(provide 'caml-pack)
;;; caml-pack ends here
