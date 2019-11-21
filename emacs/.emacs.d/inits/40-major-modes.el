(require 'company)
(require 'flycheck)

(require 'dockerfile-mode)
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

;;Haskell
(require 'haskell-mode)
;;(require 'company-ghc)
(defun setup-haskell-mode ()
  (interactive)
  (turn-on-haskell-indentation)
  (turn-on-haskell-doc-mode)
  ;;(with-eval-after-load 'company
  ;;  (add-to-list 'company-backends 'company-ghc))
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
)
(add-hook 'haskell-mode-hook #'setup-haskell-mode)
(add-to-list 'auto-mode-alist '("\\.hs\\'" . haskell-mode))
(add-to-list 'auto-mode-alist '("\\.tidal\\'" . haskell-mode))

(require 'json-mode)
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))

;; Markdown
(require 'markdown-mode)
(require 'writeroom-mode)
(defun setup-markdown-mode ()
  (interactive)
  (writeroom-mode +1)
)
(add-hook 'markdown-mode-hook #'setup-markdown-mode)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(require 'mustache-mode)
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . mustache-mode))

(require 'nginx-mode)
(add-to-list 'auto-mode-alist '("/nginx/sites-\\(?:available\\|enabled\\)/" . nginx-mode))

(require 'nix-mode)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

;;PlantUML
(require 'plantuml-mode)
(add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
(add-to-list 'auto-mode-alist '("\\.pu\\'" . plantuml-mode))
(setq plantuml-jar-path "/usr/share/plantuml/plantuml.jar")
(setq plantuml-output-type "svg")
(setq plantuml-options "-charset UTF-8")

(require 'pug-mode)
(add-to-list 'auto-mode-alist '("\\.pug\\'" . pug-mode))
(add-to-list 'auto-mode-alist '("\\.jade\\'" . pug-mode))

;;Ruby
(require 'robe)
(require 'ruby-electric)
(custom-set-variables
 '(ruby-insert-encoding-magic-comment nil))
(add-hook 'ruby-mode-hook '
          '(lambda ()
            (robe-mode t)
            (push 'company-robe company-backends)
            (flymake-ruby-load)
            (ruby-electric-mode t)
            (setq ruby-electric-expand-delimiters-list nil)
            ))


;;Rust
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
  (global-flycheck-mode +1)
)
;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)
(add-hook 'rust-mode-hook #'setup-rust-mode)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

(require 'terraform-mode)
(add-to-list 'auto-mode-alist '("\\.tf\\'" . terraform-mode))

(require 'tidal)
(add-to-list 'auto-mode-alist '("\\.tidal\\'" . tidal-mode))

;;Typescript
(require 'tide)
(require 'web-mode)
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
)
(add-hook 'typescript-mode-hook #'setup-tide-mode)
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (setup-tide-mode))))

(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

;;Java
(require 'meghanada)
(add-hook 'java-mode-hook
          (lambda ()
            ;; meghanada-mode on
            (meghanada-mode t)
            ;; enable telemetry
            (meghanada-telemetry-enable t)
            (flycheck-mode +1)
            (setq c-basic-offset 2)
            ;; use code format
            (add-hook 'before-save-hook 'meghanada-code-beautify-before-save)))
(cond
   ((eq system-type 'windows-nt)
    (setq meghanada-java-path (expand-file-name "bin/java.exe" (getenv "JAVA_HOME")))
    (setq meghanada-maven-path "mvn.cmd"))
   (t
    (setq meghanada-java-path "java")
    (setq meghanada-maven-path "mvn")))
