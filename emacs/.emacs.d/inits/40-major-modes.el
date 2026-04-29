;;; 40-major-modes.el --- Major mode setup  -*- lexical-binding: t; -*-

;; Dockerfile
(use-package dockerfile-mode
  :ensure t
  :defer t
  :mode "Dockerfile\\'")

;; Haskell
(use-package haskell-mode
  :ensure t
  :defer t
  :mode "\\.hs\\'"
  :config
  (turn-on-haskell-indentation)
  (turn-on-haskell-doc-mode))

(use-package tidal
  :ensure t
  :defer t
  :mode "\\.tidal\\'"
  :config
  (setq tidal-interpreter "~/bin/stack-ghci"))

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
  :defer t)

;; Rust
(use-package rust-mode
  :ensure t
  :defer t
  :mode "\\.rs\\'")

;; Terraform
(use-package terraform-mode
  :ensure t
  :defer t
  :mode "\\.tf\\'")

;; TypeScript / TSX (built-in tree-sitter modes; install grammars via
;; M-x treesit-install-language-grammar typescript / tsx)
(add-to-list 'auto-mode-alist '("\\.ts\\'"  . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(setq typescript-ts-mode-indent-offset 2)

;; HTML
(use-package web-mode
  :ensure t
  :defer t
  :mode "\\.html\\'")

;; Go
(use-package go-mode
  :ensure t
  :defer t
  :mode "\\.go\\'")

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

;; Eglot (built-in LSP) — replaces tide / robe / company-go / go-eldoc / lsp-mode
(use-package eglot
  :defer t
  :hook ((typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode        . eglot-ensure)
         (ruby-mode          . eglot-ensure)
         (rust-mode          . eglot-ensure)
         (go-mode            . eglot-ensure)
         (haskell-mode       . eglot-ensure)
         (terraform-mode     . eglot-ensure))
  :config
  ;; Use ruby-lsp (managed by mise) instead of eglot's default solargraph
  (add-to-list 'eglot-server-programs '(ruby-mode . ("ruby-lsp"))))
