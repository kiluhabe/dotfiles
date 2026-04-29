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
(setq dired-kill-when-opening-new-dired-buffer t)
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)
(global-auto-revert-mode 1)

;; dired side-window as a lightweight file tree
(defvar my/sidebar-buffer-name "*sidebar*")

(defvar my/sidebar-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") #'my/sidebar-find-file)
    (define-key map (kbd "<mouse-1>") #'my/sidebar-find-file)
    map))

(define-minor-mode my/sidebar-mode
  "Minor mode for the dired sidebar buffer."
  :keymap my/sidebar-mode-map
  (when my/sidebar-mode
    (tab-line-mode -1)))

(defun my/sidebar-find-file ()
  "RET in the sidebar: dirs navigate in place, files open in the main area."
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (cond
     ((file-directory-p file)
      (let ((win (selected-window)))
        (set-window-dedicated-p win nil)
        (find-alternate-file file)
        (rename-buffer my/sidebar-buffer-name)
        (my/sidebar-mode 1)
        (set-window-dedicated-p win 'side)))
     (t
      (let ((buf (find-file-noselect file)))
        (select-window
         (display-buffer
          buf
          '((display-buffer-reuse-window
             display-buffer-use-some-window
             display-buffer-pop-up-window)
            (inhibit-same-window . t)))))))))

(defun my/sidebar--prepare (buf)
  (with-current-buffer buf
    (unless (string= (buffer-name) my/sidebar-buffer-name)
      (rename-buffer my/sidebar-buffer-name))
    (my/sidebar-mode 1)))

(defun my/sidebar-toggle ()
  "Toggle a dired side-window on the left."
  (interactive)
  (if-let ((win (get-buffer-window my/sidebar-buffer-name)))
      (delete-window win)
    (let* ((root (or (and (project-current) (project-root (project-current)))
                     default-directory))
           (buf (or (get-buffer my/sidebar-buffer-name)
                    (let ((b (dired-noselect root)))
                      (my/sidebar--prepare b)
                      b))))
      (display-buffer-in-side-window
       buf
       '((side . left)
         (slot . 0)
         (window-width . 32)
         (preserve-size . (t . nil))))
      (select-window (get-buffer-window buf)))))

(global-set-key (kbd "<f8>") #'my/sidebar-toggle)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; appearance
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?┃))
(set-face-inverse-video-p 'vertical-border nil)

;; minibuffer completion (replaces ivy/counsel/swiper)
(fido-vertical-mode 1)
(setq completion-styles '(flex basic))
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
(global-set-key (kbd "C-c s") 'project-find-regexp)
(when (fboundp 'yank-from-kill-ring)
  (global-set-key (kbd "M-y") 'yank-from-kill-ring))

;; tab-bar (workspace-level tabs)
(setq tab-bar-show 1)
(global-set-key (kbd "M-n") 'tab-bar-switch-to-next-tab)
(global-set-key (kbd "M-p") 'tab-bar-switch-to-prev-tab)

;; tab-line: VSCode-like buffer tabs at the top of each window
(setq tab-line-new-button-show nil)
(setq tab-line-close-button-show nil)

(defvar my/tab-line-buffers nil
  "File-visiting buffers in their original open order (for tab-line).")

(defun my/tab-line-track ()
  "Append the current buffer to `my/tab-line-buffers' if file-visiting."
  (let ((b (current-buffer)))
    (when (and (buffer-file-name b)
               (not (memq b my/tab-line-buffers)))
      (setq my/tab-line-buffers
            (append my/tab-line-buffers (list b))))))

(add-hook 'find-file-hook #'my/tab-line-track)

(defun my/tab-line-buffers-fn ()
  "Return tab-line buffers in stable open order."
  (setq my/tab-line-buffers
        (seq-filter #'buffer-live-p my/tab-line-buffers))
  (dolist (b (reverse (buffer-list)))
    (when (and (buffer-file-name b)
               (not (memq b my/tab-line-buffers)))
      (setq my/tab-line-buffers
            (append my/tab-line-buffers (list b)))))
  my/tab-line-buffers)

(setq tab-line-tabs-function #'my/tab-line-buffers-fn)
(global-tab-line-mode 1)
(global-set-key (kbd "M-p") 'tab-line-switch-to-prev-tab)
(global-set-key (kbd "M-n") 'tab-line-switch-to-next-tab)

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
