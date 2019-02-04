(require 'fiplr)

(global-set-key (kbd "C-c C-f") 'fiplr-find-file)

(setq fiplr-root-markers '(".git" ".svn"))
(setq fiplr-ignored-globs '((directories (".git" ".svn" "node_modules" "vendor/bundle" "elpa"))
                            (files ("*.jpg" "*.png" "*.zip"))))
