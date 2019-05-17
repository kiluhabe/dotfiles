(require 'projectile)
(require 'treemacs)
(require 'treemacs-projectile)

(projectile-global-mode +1)
(setq projectile-enable-caching t)

(treemacs)
(treemacs-follow-mode t)
(treemacs-filewatch-mode t)
(setq treemacs-width 24)
(setq treemacs-file-event-delay 500)
(setq treemacs-collapse-dirs 3)

(treemacs-git-mode 'simple)

(global-set-key [f8] 'treemacs)
(projectile-discover-projects-in-directory)
(treemacs-projectile)
