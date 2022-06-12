(use-package flycheck
  :ensure t
  :defer t
  :hook (after-init . global-flycheck-mode)
  :config
  (set-face-attribute 'flycheck-error nil :foreground "red"))
