(setq make-backup-files nil)
(setq auto-save-default nil)
(setq auto-save-list-file-prefix nil)
(setq create-lockfiles nil)

(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(menu-bar-mode -1)
(setq-default indent-tabs-mode nil)

(setq indent-tabs-mode nil)
(setq-default indent-tabs-mode nil)

(require 'easy-repeat)
(easy-repeat-mode t)

(setq vc-handled-backends ())

(require 'wgrep nil t)

(electric-pair-mode t)

(require 'which-key)
(which-key-setup-side-window-bottom)
(which-key-mode t)
(setq which-key-idle-delay 0.5)

(defun custom-new-buffer-frame ()
  "Create a new frame with a new empty buffer."
  (interactive)
  (let ((buffer (generate-new-buffer "untitled")))
    (set-buffer-major-mode buffer)
    (display-buffer buffer '(display-buffer-pop-up-frame . nil))))
(global-set-key (kbd "C-c n") #'custom-new-buffer-frame)
