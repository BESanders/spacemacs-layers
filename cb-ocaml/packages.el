;;; packages.el --- cb-ocaml Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2014 Sylvain Benner
;; Copyright (c) 2014-2015 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defconst cb-ocaml-packages
  '(merlin
    tuareg
    utop
    flycheck-ocaml
    aggressive-indent
    (smart-ops :location local)))

(eval-when-compile
  (require 'dash)
  (require 's)
  (require 'use-package nil t))

(defun cb-ocaml/post-init-tuareg ()
  (with-eval-after-load 'tuareg
    (core/remap-face 'tuareg-font-lock-governing-face 'font-lock-keyword-face)
    (core/remap-face 'tuareg-font-lock-operator-face 'default)

    (define-key tuareg-mode-map (kbd "M-RET") 'cb-ocaml/m-ret))

  (font-lock-add-keywords
   'tuareg-mode
   `(,(core/font-lock-replace-match (rx space (group "->") space) 1 "→")
     ("->" . font-lock-keyword-face)
     (,(rx (or bol space) "|" (or eol space)) . font-lock-keyword-face)
     )))

(defun cb-ocaml/post-init-utop ()
  (with-eval-after-load 'merlin
    (define-key merlin-mode-map (kbd "C-c C-.") 'merlin-locate)
    (define-key merlin-mode-map (kbd "C-c C-l") nil))

  (with-eval-after-load 'utop
    (define-key utop-minor-mode-map (kbd "C-c C-l") 'utop-eval-buffer)
    (define-key utop-minor-mode-map (kbd "C-c C-z") 'utop)))

(defun cb-ocaml/post-init-merlin ()
  (with-eval-after-load 'company
    (add-to-list 'company-backends 'merlin-company-backend)))

(defun cb-ocaml/init-flycheck-ocaml ()
  (with-eval-after-load 'merlin
    ;; Disable Merlin's own error checking
    (setq merlin-error-after-save nil)
    (flycheck-ocaml-setup)))

(defun cb-ocaml/post-init-aggressive-indent ()
  (with-eval-after-load 'aggressive-indent
    (add-to-list 'aggressive-indent-excluded-modes 'tuareg-mode)
    (add-to-list 'aggressive-indent-excluded-modes 'utop-mode)))

(defun cb-ocaml/post-init-smart-ops ()
  (let ((common-ops
         (-flatten-n 1
                     (list
                      (smart-ops "@" "^")
                      (smart-ops "," ";" :pad-before nil)
                      (smart-ops "." :pad-before nil :pad-after nil)
                      (smart-ops "~" :pad-after nil)
                      (smart-ops ":"
                                 :pad-unless
                                 (lambda (pos)
                                   (save-excursion
                                     (skip-chars-backward "_:[:alnum:]")
                                     (equal ?~ (char-before)))))

                      (smart-ops-default-ops)))))

    (define-smart-ops-for-mode 'tuareg-mode
      common-ops
      (smart-ops ";;"
                 :pad-before nil
                 :pad-after nil
                 :action
                 (lambda (&rest _)
                   (comment-indent-new-line))))
    (define-smart-ops-for-mode 'utop-mode
      common-ops
      (smart-ops ";;"
                 :pad-before nil
                 :pad-after nil
                 :action
                 (lambda (&rest _)
                   (call-interactively 'utop-eval-input))))))
