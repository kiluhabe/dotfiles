(use-package undo-tree
  :ensure t
  :defer t
  :bind (("ESC z" . undo-tree-undo)
         ("ESC Z" . undo-tree-redo))
  :config
  (global-undo-tree-mode))
