(require 'js2-mode)
(require 'flycheck)
(require 'company)

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

(defun setup-js2-mode ()
  (interactive)
  (setq js2-basic-offset 2)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(idle-change mode-enabled new-line save))
  (set-face-attribute 'flycheck-error nil :background "DarkRed")
  (company-mode +1)
  (setq company-idle-delay 0.1)
  (setq company-minimum-prefix-length 2)
)

(add-hook 'js2-mode-hook #'setup-js2-mode)
