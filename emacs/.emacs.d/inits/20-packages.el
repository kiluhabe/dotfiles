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
    company
    company-racer
    company-statistics
    counsel
    dockerfile-mode
    easy-repeat
    expand-region
    faust-mode
    fiplr
    flycheck
    flycheck-rust
    haskell-mode
    ivy
    json-mode
    markdown-mode
    multiple-cursors
    mustache-mode
    nginx-mode
    nix-mode
    plantuml-mode
    projectile
    pug-mode
    racer
    rjsx-mode
    robe
    ruby-electric
    rust-mode
    swiper
    tabbar
    terraform-mode
    tidal
    tide
    treemacs
    treemacs-projectile
    undo-tree
    visual-regexp
    wgrep
    which-key
    writeroom-mode
    xresources-theme
    yaml-mode
    yasnippet
  )
)

(let ((not-installed (loop for x in installing-package-list
                            when (not (package-installed-p x))
                            collect x)))
  (when not-installed
    (package-refresh-contents)
    (dolist (pkg not-installed)
        (package-install pkg))))
