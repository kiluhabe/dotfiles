;; avoid making temp files.
(setq make-backup-files nil)
(setq create-lockfiles nil)

;; avoid auto save.
(setq auto-save-default nil)
(setq auto-save-list-file-prefix nil)

;; indent as space
(setq-default indent-tabs-mode nil)

;; disable version control
(setq vc-handled-backends ())

(electric-pair-mode t)

;; simple dired
(add-hook 'dired-mode-hook (lambda () (dired-hide-details-mode 1)))
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; appearance
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(menu-bar-mode -1)
(set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?┃))
(set-face-inverse-video-p 'vertical-border nil)
(show-paren-mode 1)
(setq show-paren-style 'parenthesis)

;; language
(setq locale-coding-system 'utf-8) ; pretty
(set-terminal-coding-system 'utf-8) ; pretty
(set-keyboard-coding-system 'utf-8) ; pretty
(set-selection-coding-system 'utf-8) ; please
(prefer-coding-system 'utf-8) ; with sugar on top

(defun custom-new-buffer-frame ()
  "Create a new frame with a new empty buffer."
  (interactive)
  (let ((buffer (generate-new-buffer "untitled")))
    (set-buffer-major-mode buffer)
    (display-buffer buffer '(display-buffer-pop-up-frame . nil))))
(global-set-key (kbd "C-c n") #'custom-new-buffer-frame)
