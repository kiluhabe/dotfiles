(require 'haskell-mode)
;;(require 'company-ghc)

(defun setup-haskell-mode ()
  (interactive)

  (turn-on-haskell-indentation)
  (turn-on-haskell-doc-mode)

  ;;(with-eval-after-load 'company
  ;;  (add-to-list 'company-backends 'company-ghc))
  (setq flycheck-check-syntax-automatically '(save mode-enabled))

  (flycheck-mode +1)
  (eldoc-mode +1)
  (company-mode +1)
)

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

(add-hook 'haskell-mode-hook #'setup-haskell-mode)

(add-to-list 'auto-mode-alist '("\\.hs\\'" . haskell-mode))
(add-to-list 'auto-mode-alist '("\\.tidal\\'" . haskell-mode))
