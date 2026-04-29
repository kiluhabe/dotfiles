;;; early-init.el --- Pre-init configuration  -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(setq frame-inhibit-implied-resize t)

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

(setq native-comp-async-report-warnings-errors 'silent)

(provide 'early-init)
;;; early-init.el ends here
