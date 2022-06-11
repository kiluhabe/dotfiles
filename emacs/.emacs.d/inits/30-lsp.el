(use-package lsp-mode
  :ensure t
  :defer t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :commands
  (lsp lsp-deferred)
  :config
  (lsp-enable-which-key-integration)
  (eldoc-mode +1))

(use-package lsp-ui
  :ensure t
  :defer t
  :after lsp-mode
  :hook lsp-mode
  :commands (lsp-ui-mode))
