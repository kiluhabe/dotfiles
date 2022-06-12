(use-package which-key
  :ensure t
  :defer t
  :hook (after-init . which-key-mode)
  :config
  (which-key-setup-side-window-bottom)
  (setq which-key-idle-delay 0.5))
