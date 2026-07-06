;; Emacs custom configuration for running code
(global-set-key (kbd "<f5>") 'compile)
(setq-default compile-command "python3 ")

;; Enable line numbers and syntax highlighting
(global-display-line-numbers-mode t)
(show-paren-mode 1)
