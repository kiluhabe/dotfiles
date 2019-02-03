(require 'company)
(require 'company-statistics)

(global-company-mode)
(company-statistics-mode)

(setq company-idle-delay 0)
(setq company-minimum-prefix-length 2)
(setq company-selection-wrap-around t)
(setq company-dabbrev-downcase nil)

(set-face-attribute 'company-tooltip nil
                    :foreground "gainsboro" :background "#262626")
(set-face-attribute 'company-tooltip-common nil
                    :foreground "gainsboro" :background "#262626")
(set-face-attribute 'company-tooltip-common-selection nil
                    :foreground "#1e90ff" :background "#104e8b")
(set-face-attribute 'company-tooltip-selection nil
                    :foreground "gainsboro" :background "#104e8b")
(set-face-attribute 'company-preview-common nil
                    :background "#104e8b" :foreground "gainsboro" :underline t)
(set-face-attribute 'company-scrollbar-fg nil
                    :background "#262626")
(set-face-attribute 'company-scrollbar-bg nil
                    :background "#262626")
