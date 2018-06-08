(require 'smooth-scroll)
(smooth-scroll-mode t)

(define-key global-map (kbd "ESC <up>") 'scroll-down)
(define-key global-map (kbd "ESC <down>") 'scroll-up)
