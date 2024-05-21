(use-package lsp-mode
  :ensure t
  :defer t
  (setq lsp-keymap-prefix "C-c l")
  :commands (lsp lsp-deferred))

(use-package lsp-ui
  :ensure t
  :defer t
  :hook lsp-mode)
