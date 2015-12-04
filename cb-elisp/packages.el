;;; packages.el --- cb-elisp Layer packages File for Spacemacs
;;; Commentary:
;;; Code:

(eval-when-compile
  (require 'use-package nil t)
  (require 's nil t)
  (require 'dash nil t))

(defconst cb-elisp-packages
  '(eldoc
    eval-sexp-fu
    dash
    hl-sexp
    highlight-defined
    smart-ops
    checkdoc
    flycheck-cask))

(defun cb-elisp/post-init-eldoc ()
  (add-hook 'emacs-lisp-mode-hook 'eldoc-mode))

(defun cb-elisp/post-init-eval-sexp-fu ()
  (defun cb-elisp/configure-eval-sexp-fu ()
    (core/remap-face 'eval-sexp-fu-flash 'core/bg-flash)
    (core/remap-face 'eval-sexp-fu-flash-error 'core/bg-flash-red)
    (turn-on-eval-sexp-fu-flash-mode))

  (add-hook 'emacs-lisp-mode-hook 'cb-elisp/configure-eval-sexp-fu)

  (define-eval-sexp-fu-flash-command elisp/eval-dwim
    (eval-sexp-fu-flash
     (-let [(&plist :beg beg :end end) (elisp/thing-for-eval)]
       (cons beg end)))))

(defun cb-elisp/post-init-dash ()
  (dash-enable-font-lock))

(defun cb-elisp/init-flycheck-cask ()
  (use-package flycheck-cask
    :commands flycheck-cask-setup))

(defun cb-elisp/init-hl-sexp ()
  (use-package hl-sexp
    :defer t
    :init (add-hook 'emacs-lisp-mode-hook 'hl-sexp-mode)
    :config
    (core/remap-face 'hl-sexp-face 'core/bg-hl-ok)))

(defun cb-elisp/init-highlight-defined ()
  (use-package highlight-defined
    :defer t
    :commands 'highlight-defined-mode
    :init
    (add-hook 'emacs-lisp-mode-hook 'highlight-defined-mode)
    :config
    (progn
      (custom-set-faces
       `(highlight-defined-function-name-face
         ((((background dark))  (:foreground "#708784"))
          (((background light)) (:foreground "#708784"))))
       `(highlight-defined-builtin-function-name-face ((t (:foreground ,solarized-hl-cyan))))
       `(highlight-defined-special-form-name-face ((t (:italic t))))
       `(highlight-defined-face-name-face
         ((((background dark))  (:foreground "#8D88AE"))
          (((background light)) (:foreground "#706D84"))))))))

(defun cb-elisp/post-init-smart-ops ()
  (define-smart-ops-for-mode 'emacs-lisp-mode
    (smart-ops "." ",@" "," :pad-before t :pad-after nil)))

(defun cb-elisp/init-checkdoc ()
  (setq checkdoc-force-docstrings-flag nil)
  (setq checkdoc-arguments-in-order-flag nil))
