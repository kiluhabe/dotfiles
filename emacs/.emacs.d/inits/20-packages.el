(require 'package)
;; MELPAを追加
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; MELPA-stableを追加
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; Marmaladeを追加
(add-to-list 'package-archives  '("marmalade" . "http://marmalade-repo.org/packages/") t)
;; Orgを追加
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

(require 'cl)

(defvar installing-package-list
  '(
    auto-complete
    cl-lib
    dash
    company
    company-box
    company-go
    company-statistics
    counsel
    dockerfile-mode
    easy-repeat
    expand-region
    fiplr
    flycheck
    go-eldoc
    go-mode
    graphql-mode
    haskell-mode
    ivy
    js2-mode
    json-mode
    lsp-mode
    lsp-ui
    markdown-mode
    multiple-cursors
    projectile
    rjsx-mode
    robe
    ruby-electric
    rustic
    slim-mode
    swiper
    tabbar
    terraform-mode
    theme-magic
    tidal
    tide
    treemacs
    treemacs-projectile
    undo-tree
    use-package
    visual-regexp
    web-mode
    wgrep
    which-key
    writeroom-mode
    xresources-theme
    yaml-mode
  )
)

(let ((not-installed (loop for x in installing-package-list
                            when (not (package-installed-p x))
                            collect x)))
  (when not-installed
    (package-refresh-contents)
    (dolist (pkg not-installed)
        (package-install pkg))))
