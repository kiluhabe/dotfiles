;; clispをデフォルトのCommon Lisp処理系に設定
(setq inferior-lisp-program "clisp")
;; SLIMEのロード
(require 'slime)
(slime-setup '(slime-repl slime-fancy slime-banner)) 
