(defun my/update-git-branch-mode-line ()
  (let* ((branch (replace-regexp-in-string
                  "[\r\n]+\\'" ""
                  (shell-command-to-string "git symbolic-ref -q HEAD")))
         (mode-line-str (if (string-match "^refs/heads/" branch)
                            (format "%s" (substring branch 11))
"[Not Repo]"))) mode-line-str))

(setq-default mode-line-format
  (list
    "      "
    (propertize (my/update-git-branch-mode-line))
    "                                                                           "
    ;; line and column
    "L:" ;; '%02' to set to 2 chars at least; prevents flickering
    (propertize "%02l")
    ", "
    "C:"
    (propertize "%02c")
    "    "
    ;; the current major mode for the buffer.
    (propertize "%m" 'face 'font-lock-string-face
              'help-echo buffer-file-coding-system)
    "    "
    ;; was this buffer modified since the last save?
    '(:eval (when (buffer-modified-p)
              (propertize "●"
                             'face '((t (:foreground "#ffa500")))
                             'help-echo "Buffer has been modified")))
    "    "
    ;; is this buffer read-only?
    '(:eval (when buffer-read-only
              (propertize "ReadOnly" 'help-echo "Buffer is read-only"))))
    )
