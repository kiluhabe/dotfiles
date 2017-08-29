;; タブの無効化
(setq-default indent-tabs-mode nil)
;; 閉じ記号の自動挿入
(electric-pair-mode 1)
;; インデント設定
(electric-indent-mode -1)

(require 'easy-repeat)


(require 'xclip)
(xclip-mode 1)
(cond (window-system
  (setq x-select-enable-clipboard t)
))
