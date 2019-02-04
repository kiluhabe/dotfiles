(require 'ivy)
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)
(setq ivy-height 10)
(setq ivy-extra-directories nil)
(setq ivy-re-builders-alist
      '((t . ivy--regex-plus)))

;; swiper
(global-set-key "\C-s" 'swiper)
