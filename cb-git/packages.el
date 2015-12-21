;;; packages.el --- cb-git Layer packages File for Spacemacs
;;; Commentary:
;;; Code:

(eval-when-compile
  (require 'use-package nil t))

(defconst cb-git-packages
  '(magit
    vc
    git-auto-commit-mode))

(defun cb-git/init-vc ()
  (setq vc-follow-symlinks t))

(defun cb-git/pre-init-magit ()
  (setenv "GIT_EDITOR" "emacsclient"))

(defun cb-git/post-init-magit ()
  ;; Remove broken Spacemacs customisation
  (remove-hook 'git-commit-mode-hook 'fci-mode)

  (core/remap-face 'magit-section-highlight 'core/bg-hl-ok)
  (core/remap-face 'magit-diff-context-highlight 'core/bg-hl-ok)

  (evil-set-initial-state 'git-commit-mode 'insert)

  (with-eval-after-load 'magit
    (define-key magit-status-mode-map (kbd "&") 'git/browse-repo)))

(defun cb-git/init-git-auto-commit-mode ()
  (use-package git-auto-commit-mode
    :diminish git-auto-commit-mode
    :init
    (add-to-list 'safe-local-variable-values '(gac-automatically-push-p . t))))
