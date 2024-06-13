(use-package lsp-mode
  :ensure t
  :config
  (setq lsp-keymap-prefix "C-c l")
  :commands (lsp lsp-deferred))

(use-package lsp-ui
  :ensure t
  :hook lsp-mode)
