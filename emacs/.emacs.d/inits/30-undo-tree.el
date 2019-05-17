(require 'undo-tree)
(global-undo-tree-mode)

(define-key global-map (kbd "ESC z") 'undo-tree-undo)
(define-key global-map (kbd "ESC Z") 'undo-tree-redo)
