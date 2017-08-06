;; ツールバーを非表示
(tool-bar-mode -1)
;; メニューバーを非表示
(menu-bar-mode -1)

(global-linum-mode 1)
(eval-after-load 'linum
  '(progn
     (defface linum-leading-zero
       `((t :inherit 'linum
       :foreground ,(face-attribute 'linum :background nil t)))
       "Face for displaying leading zeroes for line numbers in display margin."
       :group 'linum)

     (defun linum-format-func (line)
    (let ((w (length (number-to-string (count-lines (point-min) (point-max))))))
       (propertize (format (format "%%%dd " w) line) 'face 'linum)))
     (setq linum-format 'linum-format-func)))

(when (string= system-type "darwin")
  (setq dired-use-ls-dired nil))

(set-face-background 'default "#1E1E1E")

(require 'whitespace)
;; タブの色
(set-face-foreground 'whitespace-tab "DarkRed")
(set-face-underline  'whitespace-tab t)
(set-face-background 'whitespace-tab nil)
;; spaceの色
(set-face-foreground 'whitespace-space "DarkBlue")
(set-face-underline  'whitespace-space t)
(set-face-background 'whitespace-space nil)
(global-whitespace-mode 1)
