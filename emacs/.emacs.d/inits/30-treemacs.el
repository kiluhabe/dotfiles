(require 'projectile)
(require 'treemacs)
(require 'treemacs-projectile)

(projectile-global-mode +1)
(setq projectile-enable-caching t)

(treemacs)
(treemacs-follow-mode t)
(treemacs-filewatch-mode t)
(setq treemacs-width 18)
(setq treemacs-file-event-delay 500)
(setq treemacs-collapse-dirs 3)

(treemacs-git-mode 'simple)

(set-face-foreground 'treemacs-directory-face "#dcdcdc")
(set-face-foreground 'treemacs-git-ignored-face "#696969")
(set-face-foreground 'treemacs-git-modified-face "#ffd39b")
(set-face-foreground 'treemacs-git-added-face "#696969")

(global-set-key [f8] 'treemacs)
(projectile-discover-projects-in-directory)
(treemacs-projectile)
