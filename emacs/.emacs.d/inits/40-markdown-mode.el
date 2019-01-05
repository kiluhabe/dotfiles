(require 'markdown-mode)
(require 'writeroom-mode)

(defun setup-markdown-mode ()
  (interactive)
  (writeroom-mode +1)
)

(add-hook 'markdown-mode-hook #'setup-markdown-mode)

(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
