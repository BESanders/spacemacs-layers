;;; extensions.el --- cb-agda Layer packages File for Spacemacs
;;; Commentary:
;;; Code:

(eval-when-compile
  (require 'use-package nil t))

(defconst cb-agda-packages
  '(agda-mode
    smart-ops
    aggressive-indent))

(defun cb-agda/post-init-smart-ops ()
  (define-smart-ops-for-mode 'agda2-mode
    (smart-ops-default-ops)
    (smart-op "$")))

(defun cb-agda/post-init-aggressive-indent ()
  (with-eval-after-load 'aggressive-indent
    (add-to-list 'aggressive-indent-excluded-modes 'agda2-mode)))

(defun cb-agda/init-agda-mode ()
  (use-package agda-mode
    :config
    (progn

      ;;; Keybindings

      (define-key agda2-mode-map (kbd "M-RET") #'agda/meta-ret)
      (define-key agda2-mode-map (kbd "M-N") #'agda2-next-goal)
      (define-key agda2-mode-map (kbd "M-P") #'agda2-previous-goal)

      (evil-define-key 'normal agda2-mode-map
        ",l" #'agda2-load
        ",c" #'agda2-make-case
        ",n" #'agda2-compute-normalised-maybe-toplevel
        (kbd ", SPC") #'agda2-give
        ",r" #'agda2-refine

        ",a" #'agda2-auto
        ",s" #'agda2-solveAll
        ",k" #'agda2-show-constraints
        ",g" #'agda2-goal-and-context
        ",t" #'agda2-infer-type

        ",h" #'agda2-display-implicit-arguments
        ",R" #'agda2-restart

        (kbd "M-.") #'agda2-goto-definition-keyboard
        (kbd "M-,") #'agda2-go-back

        ",x" #'agda2-restart)

      (defun cb-agda/configure-agda-mode-hooks ()
        (add-hook 'after-save-hook #'agda2-load nil t)
        (add-hook 'before-save-hook #'agda/rewrite-symbols-in-buffer nil t)
        (flycheck-mode -1))

      (add-hook 'agda2-mode-hook #'cb-agda/configure-agda-mode-hooks)

      ;; Editing advice

      (defun cb-agda/on-goal-navigated ()
        (agda2-goal-and-context)
        (evil-insert-state))

      (advice-add 'agda2-next-goal :after #'cb-agda/on-goal-navigated)
      (advice-add 'agda2-previous-goal :after #'cb-agda/on-goal-navigated)

      ;; Remap faces

      (core/remap-face 'agda2-highlight-error-face 'flycheck-error)
      (core/remap-face 'agda2-highlight-keyword-face 'font-lock-keyword-face)
      (core/remap-face 'agda2-highlight-bound-variable-face 'font-lock-variable-name-face)
      (core/remap-face 'agda2-highlight-module-face 'font-lock-constant-face)
      (core/remap-face 'agda2-highlight-datatype-face 'font-lock-type-face)
      (core/remap-face 'agda2-highlight-record-face 'font-lock-type-face)
      (core/remap-face 'agda2-highlight-function-face 'default)
      (core/remap-face 'agda2-highlight-primitive-type-face 'font-lock-builtin-face)
      (core/remap-face 'agda2-highlight-symbol-face 'default)

      (custom-set-faces
       `(agda2-highlight-number-face
         ((t
           (:foreground ,solarized-hl-magenta))))

       `(agda2-highlight-field-face
         ((t
           (:foreground ,solarized-hl-cyan))))

       `(agda2-highlight-inductive-constructor-face
         ((t
           (:foreground ,solarized-hl-violet :italic t))))

       `(agda2-highlight-coinductive-constructor-face
         ((t
           (:foreground ,solarized-hl-magenta :italic t))))))))
