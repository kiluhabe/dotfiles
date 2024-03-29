(use-package fiplr
  :ensure t
  :defer t
  :bind ("C-c C-f" . fiplr-find-file)
  :config
  (setq fiplr-root-markers '(".git" ".svn"))
  (setq fiplr-ignored-globs '((directories (".git" ".svn" "node_modules" "vendor/bundle" "elpa"))
                              (files ("*.jpg" "*.png" "*.zip")))))
