;;; init.el --- User initialization  -*- lexical-binding: t; -*-

(dolist (file (directory-files
               (expand-file-name "inits" user-emacs-directory)
               t "\\`[0-9]\\{2\\}.*\\.el\\'"))
  (load (file-name-sans-extension file) nil 'nomessage))

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))
(setq custom-theme-directory
      (expand-file-name "themes" user-emacs-directory))
(load-theme 'twilight t)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 )

;;; init.el ends here
