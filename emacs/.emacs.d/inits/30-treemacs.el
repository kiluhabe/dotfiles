(use-package projectile
             :ensure t
             :defer t
             :commands (projectile-discover-projects-in-directory)
             :config
             (setq projectile-enable-caching t))

(use-package treemacs
             :ensure t
             :defer t
             :hook (after-init . treemacs)
             :config
             (treemacs-follow-mode t)
             (treemacs-filewatch-mode t)
             (setq treemacs-width 24)
             (setq treemacs-file-event-delay 500)
             (setq treemacs-collapse-dirs 3)
             (treemacs-git-mode 'simple)
             :bind (("<f8>" . treemacs))
             )

(use-package treemacs-projectile
             :after (treemacs projectile)
             :ensure t)
