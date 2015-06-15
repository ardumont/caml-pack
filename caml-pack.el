;;; caml-pack.el --- Caml

;;; Commentary:

;;; Code:

(use-package smartscan)

(use-package tuareg
  :init (progn
          (add-hook 'tuareg-mode-hook (lambda () (smartscan-mode)))
          (defun switch-to-caml-buffer ()
            "Switch to the caml buffer if needed."
            (interactive)
            ;; will trigger a caml buffer if needed
            (tuareg-run-process-if-needed)
            (pop-to-buffer tuareg-interactive-buffer-name)))

  :config (custom-set-variables '(tuareg-comment-end-extra-indent 1) ;; multi line comments
                                '(tuareg-interactive-scroll-to-bottom-on-output t)) ;; make the interactive buffer scroll if needed

  :bind ("C-c C-z" . switch-to-caml-buffer))

(provide 'caml-pack)
;;; caml-pack ends here
