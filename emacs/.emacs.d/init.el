;;; init.el --- User initialization  -*- lexical-binding: t; -*-

(dolist (file (directory-files
               (expand-file-name "inits" user-emacs-directory)
               t "\\`[0-9]\\{2\\}.*\\.el\\'"))
  (load (file-name-sans-extension file) nil 'nomessage))

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))
;; Theme is loaded via inits/30-theme.el (vscode-dark-plus).

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;;; init.el ends here
