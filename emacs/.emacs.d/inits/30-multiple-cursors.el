(use-package multiple-cursors
             :config
             (multiple-cursors-mode t)
             :bind (
             ("C-c <down>" . mc/mark-next-like-this)
             ("C-c <up>" . mc/mark-previous-like-this)
             ("C-c C-a" . mc/mark-all-like-this)))