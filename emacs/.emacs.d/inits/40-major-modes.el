;; Dockerfile
(use-package dockerfile-mode
  :ensure t
  :defer t
  :mode "Dockerfile\\'")

;;Haskell
(use-package haskell-mode
  :ensure t
  :defer t
  :mode "\\.hs\\'"
  :config
  (turn-on-haskell-indentation)
  (turn-on-haskell-doc-mode)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1))
(use-package tidal
  :ensure t
  :defer t
  :mode "\\.tidal\\'"
  :config
  (setq tidal-interpreter "~/bin/stack-ghci"))
;; (use-package company-ghc
;;   :ensure t
;;   :defer t
;;   :after company
;;   :hook (haskell-mode tidal-mode)
;;   :config
;;   (with-eval-after-load 'company
;;     (add-to-list 'company-backends 'company-ghc)))

;; JSON
(use-package json-mode
  :ensure t
  :defer t
  :mode "\\.json\\'")

;; Markdown
(use-package markdown-mode
  :ensure t
  :defer t
  :mode ("\\.md\\'" "\\.mdx\\'"))
(use-package writeroom-mode
  :ensure t
  :defer t
  :hook writeroom-mode
  :config
  (writeroom-mode +1))

;; JSX
(use-package rjsx-mode
  :ensure t
  :defer t
  :mode ("\\.jsx\\'")
  :config
  (setq js-indent-level 2)
  (setq js2-strict-missing-semi-warning nil))

;;Ruby
(use-package robe
  :ensure t
  :defer t
  :hook (ruby-mode . robe-mode)
  :config
  (setq ruby-insert-encoding-magic-comment nil)
  (push 'company-robe company-backends))
(use-package ruby-electric
  :ensure t
  :defer t
  :after robe
  :hook ruby-mode
  :config
  (setq ruby-electric-expand-delimiters-list nil))

;;Rust
(use-package rustic
  :ensure t
  :defer t
  :after lsp-mode
  :mode "\\.rs\\'"
  :config
  (setq lsp-rust-server 'rust-analyzer)
  (setq lsp-rust-analyzer-cargo-watch-command "clippy")
  (setq lsp-eldoc-render-all t))

;; Terraform
(use-package terraform-mode
  :ensure t
  :defer t
  :mode "\\.tf\\'")

;;Typescript
(use-package typescript-mode
  :ensure t
  :mode
  (("\\.ts\\'" . typescript-mode)
   ("\\.tsx\\'" . tsx-ts-mode))
  :config
  (setq typescript-indent-level 2)
  (setq typescript-ts-mode-indent-offset 2))

(use-package tide
  :ensure t
  :config
  (add-hook 'typescript-mode-hook
            (lambda ()
              (tide-setup)
              (flycheck-mode t)
              (setq flycheck-check-syntax-automatically '(save mode-enabled))
              (eldoc-mode t)
              (company-mode-on))))


;; HTML
(use-package web-mode
  :ensure t
  :defer t
  :mode ("\\.html\\'"))

;; Go
(use-package go-mode
  :ensure t
  :defer t
  :mode "\\.go\\'")
(use-package go-eldoc
  :ensure t
  :defer
  :after go-mode
  :hook (go-mode . go-eldoc-setup))
(use-package company-go
  :ensure t
  :defer t
  :after (go-mode company)
  :config
  (add-to-list 'company-backends 'company-go))

;;Javascript
;; (use-package js2-mode
;;   :ensure t
;;   :defer t
;;   :mode "\\.js\\'"
;;   :hook js-mode)

;; Slim
(use-package slim-mode
  :ensure t
  :defer t
  :mode "\\.slim\\'")

;; GraphQL
(use-package graphql-mode
  :ensure t
  :defer t
  :mode ("\\.graphql\\'" "\\.gql\\'"))
