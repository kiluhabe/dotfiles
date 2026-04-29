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

;; Show mode-line only in the selected window of each frame.
;; Inactive windows reclaim the row (mode-line-format = nil, buffer-local).
;; Same buffer in two windows: mode-line shows in both (last write wins).
(defun my/mode-line-only-active (&rest _)
  (let ((sel (frame-selected-window)))
    (dolist (win (window-list nil 'no-minibuf))
      (unless (eq win sel)
        (with-current-buffer (window-buffer win)
          (setq-local mode-line-format nil))))
    (with-current-buffer (window-buffer sel)
      (kill-local-variable 'mode-line-format))))

(add-hook 'window-selection-change-functions #'my/mode-line-only-active)
(add-hook 'window-buffer-change-functions    #'my/mode-line-only-active)
(add-hook 'window-configuration-change-hook  #'my/mode-line-only-active)
(add-hook 'after-init-hook                   #'my/mode-line-only-active)
