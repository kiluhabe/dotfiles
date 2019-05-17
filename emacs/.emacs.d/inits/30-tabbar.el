(require 'tabbar)

(tabbar-mwheel-mode -1)
(setq tabbar-use-images nil)

;; hide buttons
(dolist (btn '(tabbar-buffer-home-button
               tabbar-scroll-left-button
               tabbar-scroll-right-button))
  (set btn (cons (cons "" nil)
                 (cons "" nil))))

(custom-set-variables
'(tabbar-separator (quote (1))))


;; trim overflow tabs
(setq tabbar-auto-scroll-flag nil)

;; set padding
(defun tabbar-buffer-tab-label (tab)
  "Return a label for TAB.
That is, a string used to represent it on the tab bar."
  (let ((label  (if tabbar--buffer-show-groups
                    (format "    [%s]    " (tabbar-tab-tabset tab))
                  (format "    %s    " (tabbar-tab-value tab)))))
    ;; Unless the tab bar auto scrolls to keep the selected tab
    ;; visible, shorten the tab label to keep as many tabs as possible
    ;; in the visible area of the tab bar.
    (if tabbar-auto-scroll-flag
        label
      (tabbar-shorten
       label (max 1 (/ (window-width)
                       (length (tabbar-view
                                (tabbar-current-tabset)))))))))

(set-face-attribute
 'tabbar-default nil
 :background "black"
 :foreground "white"
 :box nil
 :underline nil
 )
(set-face-attribute
 'tabbar-selected nil
 :background "blue"
 :foreground "black"
 :box nil
 )
(set-face-attribute
 'tabbar-modified nil
 :background "black"
 :foreground "blue"
 :box nil
 )

(global-set-key (kbd "M-n") 'tabbar-forward-tab)
(global-set-key (kbd "M-p") 'tabbar-backward-tab)

(tabbar-mode)
