(require 'plantuml-mode)

(add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
(add-to-list 'auto-mode-alist '("\\.pu\\'" . plantuml-mode))

(setq plantuml-jar-path "/usr/share/plantuml/plantuml.jar")
(setq plantuml-output-type "svg")
(setq plantuml-options "-charset UTF-8")
