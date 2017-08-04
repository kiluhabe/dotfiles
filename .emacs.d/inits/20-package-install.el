(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

(require 'cl)

(defvar installing-package-list
  '(
    markdown-mode
    
    ruby-mode
    ruby-electric-mode
    inf-ruby
    rspec-mode

    typescript-mode
    rust-mode
    slime

    fly-check

    neotree
    auto-complete
    popup
    elscreen
    
    doom-themes
    all-the-icons
   ))

(let ((not-installed (loop for x in installing-package-list
                            when (not (package-installed-p x))
                            collect x)))
  (when not-installed
    (package-refresh-contents)
    (dolist (pkg not-installed)
        (package-install pkg))))
