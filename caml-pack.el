;;; caml-pack.el --- Caml

;;; Commentary:

;;; Code:

(use-package 'smartscan)

(use-package tuareg
  :init
  (add-hook 'tuareg-mode-hook (lambda () (smartscan-mode)))

  (defun switch-to-caml-buffer ()
    "Switch to the caml buffer if needed."
    (interactive)
    ;; will trigger a caml buffer if needed
    (tuareg-run-process-if-needed)
    (pop-to-buffer tuareg-interactive-buffer-name))

  ;; display-buffer--same-window-action (to permit the swich keeping the same window)
  ;; display-buffer--other-frame-action (in another frame)

  ;; multi line comments
  (setq tuareg-comment-end-extra-indent 1)

  ;; make the interactive buffer scroll if needed
  (setq tuareg-interactive-scroll-to-bottom-on-output t)

  (define-key tuareg-mode-map (kbd "C-c C-z") 'switch-to-caml-buffer))


(provide 'caml-pack)
;;; caml-pack ends here
