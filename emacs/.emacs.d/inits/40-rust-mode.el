(require 'rust-mode)
(require 'racer)
(require 'flycheck-rust)
(require 'company-racer)
(require 'company)

(defun setup-rust-mode ()
  (interactive)
  (with-eval-after-load 'company
    (add-to-list 'company-backends 'company-racer))
  (racer-mode +1)
  (flycheck-rust-setup)
  (eldoc-mode +1)
  (company-mode +1)
  (global-flycheck-mode +1)
)

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

(add-hook 'rust-mode-hook #'setup-rust-mode)

(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
