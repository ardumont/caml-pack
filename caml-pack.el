;;; caml-pack.el --- Caml

;;; Commentary:

;;; Code:

(use-package smartscan)

(use-package tuareg
  :init (defun switch-to-caml-buffer ()
          "Switch to the caml buffer if needed."
          (interactive)
          ;; will trigger a caml buffer if needed
          (tuareg-run-process-if-needed)
          (pop-to-buffer tuareg-interactive-buffer-name))

  :config (progn
            (add-hook 'tuareg-mode-hook 'smartscan-mode)
            (custom-set-variables
             ;; multi line comments
             '(tuareg-comment-end-extra-indent 1)
             ;; make the interactive buffer scroll if needed
             '(tuareg-interactive-scroll-to-bottom-on-output t)))

  :bind (("C-c C-z" . switch-to-caml-buffer)
         ("C-c C-l" . tuareg-eval-buffer)))

(provide 'caml-pack)
;;; caml-pack ends here
