(use-package counsel
  :ensure t
  :defer t
  :bind (("M-x" . counsel-M-x)
         ("M-y" . counsel-yank-pop)
         ("M-f" . counsel-fzf)
         ("M-r" . counsel-recentf))
  :config
  (defvar counsel-find-file-ignore-regexp (regexp-opt '("./" "../"))))
