(deftheme super-cool
  "super cool color theme")

(custom-theme-set-faces
  'super-cool

  '(line-number ((t (:foreground "blue" :background "black"))))
  '(line-number-current-line ((t (:foreground "yellow" :background "black"))))

  ;; 背景・文字・カーソル
  '(cursor ((t (:foreground "white"))))
  '(default ((t (:background "black" :foreground "white"))))

  ;; 選択範囲
  '(region ((t (:background "#4682b4"))))

  ;; モードライン
  '(mode-line ((t (:foreground "black" :background "blue" :box (:line-width 0)))))
  '(mode-line-buffer-id ((t (:foreground nil :background nil))))
  '(mode-line-inactive ((t (:foreground "black" :background "black" :box (:line-width 0)))))

  ;; ハイライト
  '(highlight ((t (:foreground "black" :background "#C4BE89"))))
  '(hl-line ((t (:foreground "black" :background "#27408b"))))

  ;; 関数名
  '(font-lock-function-name-face ((t (:foreground "yellow"))))

  ;; 変数名・変数の内容
  '(font-lock-variable-name-face ((t (:foreground "cyan"))))
  '(font-lock-string-face ((t (:foreground "white"))))

  ;; 特定キーワード
  '(font-lock-keyword-face ((t (:foreground "#cd96cd"))))

  ;; Boolean
  '(font-lock-constant-face((t (:foreground "#1874cd"))))

  ;; コメント
  '(font-lock-comment-face ((t (:foreground "blue"))))

  '(font-lock-type-face ((t (:foreground "#00cdcd"))))
  '(font-lock-builtin-face ((t (:foreground "#1874cd"))))

  '(dired-header ((t (:foreground "cyan"))))
  '(dired-directory ((t (:foreground "cyan"))))
  '(dired-symlink ((t (:foreground "magenta"))))

  '(vertical-border ((t (:foreground "black" :box (:line-width 0)))))
  '(show-paren-match ((t (:background "yellow" :foreground "black"))))

  '(flycheck-error ((t (:foreground "red"))))
)

(provide-theme 'super-cool)

(add-hook 'minibuffer-setup-hook
          (lambda ()
            (make-local-variable 'face-remapping-alist)
            (add-to-list 'face-remapping-alist '(default (:background "black")))))
