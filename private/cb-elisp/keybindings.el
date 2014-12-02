(define-key emacs-lisp-mode-map (kbd "M-.") 'elisp-slime-nav-find-elisp-thing-at-point)
(define-key emacs-lisp-mode-map (kbd "C-c C-t") 'ert)
(define-key emacs-lisp-mode-map (kbd "C-c C-z") 'switch-to-ielm)
(define-key emacs-lisp-mode-map (kbd "C-c C-e") 'send-to-ielm)
(define-key emacs-lisp-mode-map (kbd "C-c RET") 'eval-in-ielm)
(define-key emacs-lisp-mode-map (kbd "M-RET")   'elisp/M-RET)
(define-key emacs-lisp-mode-map (kbd "C-c C-f") 'eval-buffer)
(define-key emacs-lisp-mode-map (kbd "C-c C-b") 'eval-buffer)
(define-key emacs-lisp-mode-map (kbd "C-c C-c") 'elisp/eval-dwim)

(evil-define-key 'normal emacs-lisp-mode-map (kbd "M-.") 'elisp-slime-nav-find-elisp-thing-at-point)
(evil-define-key 'normal emacs-lisp-mode-map (kbd "K") 'elisp-slime-nav-describe-elisp-thing-at-point)

(evil-leader/set-key "ee" 'toggle-debug-on-error)
(evil-leader/set-key "el" 'find-library)
(evil-leader/set-key "ef" 'find-function)
(evil-leader/set-key "ev" 'find-variable)
(evil-leader/set-key "eF" 'find-face-definition)