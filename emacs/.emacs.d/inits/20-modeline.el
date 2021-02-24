(setq-default mode-line-format
  (list
    "  "
    ;; line and column
    (propertize "%02l")
    "/"
    (propertize "%02c")
    "  "
    ;; the current major mode for the buffer.
    (propertize "%m" 'face 'font-lock-string-face
              'help-echo buffer-file-coding-system)
    "  "
    ;; was this buffer modified since the last save?
    '(:eval (when (buffer-modified-p)
              (propertize "✗"
                             'face '((t (:foreground "#ffa500")))
                             'help-echo "Buffer has been modified")))
    "  "
    ;; is this buffer read-only?
    '(:eval (when buffer-read-only
              (propertize "ReadOnly" 'help-echo "Buffer is read-only"))))
    )
