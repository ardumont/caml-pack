;;; caml-pack.el --- Caml

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
            (message "Package '%s' is%s installed!" package (if (caml-pack/command-installed-p! package) "" " still not"))))))))

(defun caml-pack/install-ml-packages (packages)
  "Trigger cabal install of PACKAGES."
  (mapc 'caml-pack/install-ml-package packages))

(use-package smartscan)

(use-package tuareg
  :init (defun switch-to-caml-buffer ()
          "Switch to the caml buffer if needed."
          (interactive)
          ;; will trigger a caml buffer if needed
          (tuareg-run-process-if-needed)
          (pop-to-buffer tuareg-interactive-buffer-name))

  (bind-key "C-c C-z" 'switch-to-caml-buffer tuareg-mode-map)
  (bind-key "C-c C-l" 'tuareg-eval-buffer    tuareg-mode-map)

  :config (progn
            (add-hook 'tuareg-mode-hook 'smartscan-mode)
            (custom-set-variables
             ;; multi line comments
             '(tuareg-comment-end-extra-indent 1)
             ;; make the interactive buffer scroll if needed
             '(tuareg-interactive-scroll-to-bottom-on-output t))))

(caml-pack/install-ml-packages '("merlin" "ocp-indent"))

;; Add opam emacs directory to the load-path
(setq opam-share (substring (shell-command-to-string "opam config var share 2> /dev/null") 0 -1))
(add-to-list 'load-path (concat opam-share "/emacs/site-lisp"))
;; Load merlin-mode
(require merlin)
;; Start merlin on ocaml files
(add-hook 'tuareg-mode-hook 'merlin-mode t)
(add-hook 'caml-mode-hook 'merlin-mode t)
;; Enable auto-complete
(setq merlin-use-auto-complete-mode 'easy)
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
