;;; 10-base.el --- Base settings  -*- lexical-binding: t; -*-

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

(electric-pair-mode 1)
(show-paren-mode 1)
(setq show-paren-style 'parenthesis)

;; simple dired
(add-hook 'dired-mode-hook (lambda () (dired-hide-details-mode 1)))
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)
(global-auto-revert-mode 1)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; appearance
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?┃))
(set-face-inverse-video-p 'vertical-border nil)

;; minibuffer completion (replaces ivy/counsel/swiper)
(fido-vertical-mode 1)
(setq enable-recursive-minibuffers t)

;; repeat-mode (replaces easy-repeat)
(when (fboundp 'repeat-mode)
  (repeat-mode 1))

;; which-key (built-in since Emacs 30)
(when (fboundp 'which-key-mode)
  (setq which-key-idle-delay 0.5)
  (which-key-mode 1))

;; recent files
(recentf-mode 1)
(setq recentf-max-saved-items 200)

;; minibuffer history
(savehist-mode 1)

;; project.el bindings (replaces projectile/fiplr/treemacs)
(global-set-key (kbd "C-c C-f") 'project-find-file)
(global-set-key (kbd "M-f") 'project-find-file)
(global-set-key (kbd "M-r") 'recentf-open)
(when (fboundp 'yank-from-kill-ring)
  (global-set-key (kbd "M-y") 'yank-from-kill-ring))

;; tab-bar (replaces tabbar)
(setq tab-bar-show 1)
(global-set-key (kbd "M-n") 'tab-bar-switch-to-next-tab)
(global-set-key (kbd "M-p") 'tab-bar-switch-to-prev-tab)

;; language
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(defun custom-new-buffer-frame ()
  "Create a new frame with a new empty buffer."
  (interactive)
  (let ((buffer (generate-new-buffer "untitled")))
    (set-buffer-major-mode buffer)
    (display-buffer buffer '(display-buffer-pop-up-frame . nil))))
(global-set-key (kbd "C-c n") #'custom-new-buffer-frame)
