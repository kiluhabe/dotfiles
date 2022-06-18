(use-package undo-tree
  :ensure t
  :defer t
  :bind (("ESC z" . undo-tree-undo)
         ("ESC Z" . undo-tree-redo))
  :hook (after-init . global-undo-tree-mode)
  :config
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/.undo"))))2
