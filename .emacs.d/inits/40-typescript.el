(require 'typescript-mode)
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))

(require 'tide)
(add-hook 'typescript-mode-hook
          (lambda ()
            (tide-setup)
            (flycheck-mode t)
            (setq flycheck-check-syntax-automatically '(save mode-enabled))
            (eldoc-mode t)
            (company-mode-on)
            (setq typescript-indent-level 2)))

(require 'flycheck)
(flycheck-define-checker typescript-checker
"A TypeScript syntax checker using tsc command."
  :command ("tsc" "--out" "/dev/null" source)
  :error-patterns
  ((error line-start (file-name) "(" line "," column "): error " (message) line-end))
    :mode (typescript-mode))
   (add-hook 'typescript-mode-hook
     (lambda ()
       (flycheck-select-checker 'typescript-checker)
         (flycheck-mode t)
      ))
