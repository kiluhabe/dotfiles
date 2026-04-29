(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  (setq company-idle-delay 0.2)
  (setq company-minimum-prefix-length 2)
  (setq company-selection-wrap-around t)
  (setq company-dabbrev-downcase nil)
  (setq company-tooltip-align-annotations t)
  (set-face-attribute 'company-tooltip nil
                      :foreground "white" :background "black")
  (set-face-attribute 'company-tooltip-common nil
                      :foreground "white" :background "black")
  (set-face-attribute 'company-tooltip-common-selection nil
                      :foreground "black" :background "yellow")
  (set-face-attribute 'company-tooltip-selection nil
                      :foreground "black" :background "yellow")
  (set-face-attribute 'company-preview-common nil
                      :background "black" :foreground "white" :underline t))

(use-package company-box
  :ensure t
  :after company
  :hook (company-mode . company-box-mode))
