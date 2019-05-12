(require 'company)
(require 'company-statistics)

(global-company-mode)
(company-statistics-mode)

(setq company-idle-delay 0)
(setq company-minimum-prefix-length 2)
(setq company-selection-wrap-around t)
(setq company-dabbrev-downcase nil)

(set-face-attribute 'company-tooltip nil
                    :foreground "white" :background "black")
(set-face-attribute 'company-tooltip-common nil
                    :foreground "white" :background "black")
(set-face-attribute 'company-tooltip-common-selection nil
                    :foreground "black" :background "yellow")
(set-face-attribute 'company-tooltip-selection nil
                    :foreground "black" :background "yellow")
(set-face-attribute 'company-preview-common nil
                    :background "black" :foreground "white" :underline t)
(set-face-attribute 'company-scrollbar-fg nil
                    :background "black")
(set-face-attribute 'company-scrollbar-bg nil
                    :background "black")
