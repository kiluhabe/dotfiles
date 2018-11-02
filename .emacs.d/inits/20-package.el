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
    tabbar
    treemacs
    git-gutter
    projectile
    magit
    treemacs-projectile
    smooth-scroll
    easy-repeat
    ivy
    counsel
    swiper
    wgrep
    multiple-cursors
    company
    company-statistics
    expand-region
    undo-tree
    visual-regexp
    which-key
    fiplr
    markdown-mode
    yaml-mode
    json-mode
    tide
    dockerfile-mode
    rust-mode
    racer
    flycheck-rust
    company-racer
    terraform-mode
    nginx-mode
    tidal
    haskell-mode
    company-ghc
    writeroom-mode
    plantuml-mode
  )
)

(let ((not-installed (loop for x in installing-package-list
                            when (not (package-installed-p x))
                            collect x)))
  (when not-installed
    (package-refresh-contents)
    (dolist (pkg not-installed)
        (package-install pkg))))
