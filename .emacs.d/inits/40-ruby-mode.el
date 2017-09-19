(require 'flycheck)
(require 'company)
(require 'rspec-mode)
(require 'inf-ruby)

(setq ruby-insert-encoding-magic-comment nil)
(add-to-list 'auto-mode-alist
  '("\\.\\(?:cap\\|gemspec\\|irbrc\\|gemrc\\|rake\\|rb\\|ru\\|thor\\)\\'" . ruby-mode))
(add-to-list 'auto-mode-alist
  '("\\(?:Brewfile\\|Capfile\\|Gemfile\\(?:\\.[a-zA-Z0-9._-]+\\)?\\|[rR]akefile\\)\\'" . ruby-mode))


(setenv "PAGER" (executable-find "cat"))

(defun setup-ruby-mode ()
  (interactive)
  (flycheck-mode +1)
  (setq flycheck-checker 'ruby-rubocop)
  (setq flycheck-check-syntax-automatically '(idle-change mode-enabled new-line save))
  (set-face-attribute 'flycheck-error nil :background "DarkRed")

  (eval-after-load 'company
    '(push 'company-robe company-backends))
  (company-mode +1)
  (setq company-idle-delay 0.1)
  (setq company-minimum-prefix-length 1)

  (robe-mode +1)
  (rspec-mode +1)

  ;;;(inf-ruby-mode)
)


(add-hook 'ruby-mode-hook #'setup-ruby-mode)
