(use-package lsp-mode
  :ensure t
  :defer t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :after
  (lsp lsp-deferred)
  :config
  (lsp-enable-which-key-integration)
  (eldoc-mode +1))

(use-package lsp-ui
  :ensure t
  :defer t
  :hook lsp-mode)
