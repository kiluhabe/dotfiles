(require 'all-the-icons)
(require 'doom-themes)
;; Load the theme (doom-one, doom-molokai, etc); keep in mind that each theme
;; may have their own settings.
(load-theme 'doom-one t)

;; Enable flashing mode-line on errors
(doom-themes-visual-bell-config)

;; Enable custom neotree theme
(doom-themes-neotree-config)  ; all-the-icons fonts must be installed!

;; Corrects (and improves) org-mode's native fontification.
;;
;; 1. Re-set `org-todo' & `org-headline-done' faces to make them respect
;;    underlying faces (i.e. don't override the :height or :background of
;;    underlying faces).
;; 2. Make statistic cookies respect underlying faces.
;; 3. Fontify item bullets (make them stand out)
;; 4. Fontify item checkboxes (and when they're marked done), like TODOs that are
;;    marked done.
;; 5. Fontify dividers/separators (5+ dashes)
;; 6. Fontify #hashtags and @at-tags, for personal convenience; see
;;    `doom-org-special-tags' to disable this.
;; (doom-themes-org-config)
