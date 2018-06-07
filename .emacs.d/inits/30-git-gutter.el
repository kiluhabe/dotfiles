(require 'git-gutter)
(global-git-gutter-mode t)
(git-gutter:linum-setup)

(custom-set-variables
 '(git-gutter:window-width 2)
 '(git-gutter:modified-sign "・")
 '(git-gutter:added-sign "・")
 '(git-gutter:deleted-sign "・"))

(set-face-foreground 'git-gutter:modified "#ff8c00")
(set-face-foreground 'git-gutter:added "#698b69")
(set-face-foreground 'git-gutter:deleted "#b22222")