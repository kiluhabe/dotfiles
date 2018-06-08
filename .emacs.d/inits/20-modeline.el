;; use setq-default to set it for /all/ modes
(setq-default mode-line-format
  (list
    "    "
    ;; the buffer name; the file name as a tool tip
    '(:eval (propertize "%b" 'help-echo (buffer-file-name)))
    "                                                                           "
    ;; line and column
    "L:" ;; '%02' to set to 2 chars at least; prevents flickering
    (propertize "%02l")
    ", "
    "C:"
    (propertize "%02c")
    "    "
    ;; the current major mode for the buffer.
    '(:eval (propertize "%m" 'face 'font-lock-string-face
              'help-echo buffer-file-coding-system))
    "    "
    ;; was this buffer modified since the last save?
    '(:eval (when (buffer-modified-p)
              (propertize "●"
                             'face '((t (:foreground "#ffa500")))
                             'help-echo "Buffer has been modified")))
    "    "
    ;; is this buffer read-only?
    '(:eval (when buffer-read-only
              (propertize "ReadOnly" 'help-echo "Buffer is read-only")))
    ))
