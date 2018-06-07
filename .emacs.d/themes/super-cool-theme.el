(deftheme super-cool
  "super cool color theme")

(custom-theme-set-faces
  'super-cool

  '(linum ((t (:foreground "#3b3b3b"))))

  ;; 背景・文字・カーソル
  '(cursor ((t (:foreground "#4682b4"))))
  '(default ((t (:background "#1B1D1E" :foreground "#dcdcdc" :fringe (:width 50)))))

  ;; 選択範囲
  '(region ((t (:background "#4682b4"))))

  ;; モードライン
  '(mode-line ((t (:foreground "#F8F8F2" :background "#27408b" :box (:line-width 0)))))
  '(mode-line-buffer-id ((t (:foreground nil :background nil))))
  '(mode-line-inactive ((t (:foreground "#F8F8F2" :background "#708090" :box (:line-width 0)))))

  ;; ハイライト
  '(highlight ((t (:foreground "#000000" :background "#C4BE89"))))

  ;; 関数名
  '(font-lock-function-name-face ((t (:foreground "#C4BE89"))))

  ;; 変数名・変数の内容
  '(font-lock-variable-name-face ((t (:foreground "#87ceff"))))
  '(font-lock-string-face ((t (:foreground "#dcdcdc"))))

  ;; 特定キーワード
  '(font-lock-keyword-face ((t (:foreground "#1874cd"))))

  ;; Boolean
  '(font-lock-constant-face((t (:foreground "#1874cd"))))

  ;; コメント
  '(font-lock-comment-face ((t (:foreground "#698b69"))))

  '(dired-header ((t (:foreground "#1874cd"))))
  '(dired-directory ((t (:foreground "#87ceff"))))
  '(dired-symlink ((t (:foreground "#ff00ff"))))
)

(custom-theme-set-variables
  'super-cool

  (add-hook 'find-file-hook 'linum-mode)
  '(linum-format "%5d    ")
  '(show-paren-mode 1)
  '(show-paren-style 'parenthesis)
)

(provide-theme 'super-cool)