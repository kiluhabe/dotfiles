(require 'nginx-mode)
(add-to-list 'auto-mode-alist '("/nginx/sites-\\(?:available\\|enabled\\)/" . nginx-mode))
