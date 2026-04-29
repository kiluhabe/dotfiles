;;; 30-theme.el --- Color theme  -*- lexical-binding: t; -*-

;; VSCode Dark Modern: no direct port exists; vscode-dark-plus is the
;; closest maintained Emacs theme (syntax colors are essentially shared
;; between Dark+ and Dark Modern; UI chrome differs only slightly).
(use-package vscode-dark-plus-theme
  :ensure t
  :config
  (load-theme 'vscode-dark-plus t)
  ;; Restore original (twilight) backgrounds for editor / mode-line / tab-line.
  (set-face-attribute 'default               nil :background "black")
  (set-face-attribute 'mode-line             nil :background "#141414")
  (set-face-attribute 'tab-line              nil :background "#141414")
  (set-face-attribute 'tab-line-tab          nil :background "#141414")
  (set-face-attribute 'tab-line-tab-inactive nil :background "#141414")
  (set-face-attribute 'tab-line-tab-current  nil :background "black"))
