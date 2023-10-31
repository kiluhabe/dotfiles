(use-package tree-sitter
  :ensure t
  :defer t
  :hook
  (tree-sitter-after-on-hook . tree-sitter-hl-mode)
  :config (global-tree-sitter-mode))
(use-package tree-sitter-langs
  :ensure t
  :defer t
  :after tree-sitter)
