;;; packages.el --- cb-circe layer packages file for Spacemacs.  -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2012-2014 Sylvain Benner
;; Copyright (c) 2014-2016 Sylvain Benner & Contributors
;;
;; Author: Chris Barrett <chris.d.barrett@me.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `cb-circe-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `cb-circe/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another spacemacs layer, so
;;   define the functions `cb-circe/pre-init-PACKAGE' and/or
;;   `cb-circe/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(eval-when-compile
  (require 'use-package nil t))

(defconst cb-circe-packages
  '(circe
    (circe-notifications :location local)
    (circe-show-channels :location local))
  "The list of Lisp packages required by the cb-circe layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

(defun cb-circe/init-circe ()
  (use-package circe
    :commands circe
    :config
    (progn
      (set-face-background 'circe-prompt-face nil)
      (set-face-foreground 'circe-prompt-face solarized-hl-magenta)

      (defface cb-circe-self-say-face
        `((t (:weight bold :foreground ,solarized-hl-blue)))
        "The face for the Circe prompt.")

      (setq circe-reduce-lurker-spam t)
      (setq circe-active-users-timeout (* 60 30)) ; 30 minutes
      (setq circe-format-say "{nick}> {body}")
      (setq circe-format-self-say (concat (propertize ">>>" 'face 'cb-circe-self-say-face) " {body}"))
      (setq circe-prompt-string (concat (propertize ">>>" 'face 'circe-prompt-face) " "))

      ;; Timestamps in margins.

      (setq lui-time-stamp-position 'right-margin)
      (setq lui-time-stamp-format "%H:%M")
      (setq lui-fill-type nil)))

  (use-package circe-color-nicks
    :commands enable-circe-color-nicks
    :init
    (with-eval-after-load 'circe
      (enable-circe-color-nicks))
    :config
    (setq circe-color-nicks-everywhere t))

  (use-package lui
    :init
    (progn
      (defun cb-circe/set-local-vars ()
        (setq fringes-outside-margins t)
        (setq right-margin-width 5)
        (setq word-wrap t)
        (setq wrap-prefix "    "))

      (add-hook 'lui-mode-hook #'cb-circe/set-local-vars)))

  (use-package lui-autopaste
    :commands enable-lui-autopaste
    :init
    (add-hook 'circe-channel-mode-hook #'enable-lui-autopaste)))

(defun cb-circe/init-circe-notifications ()
  (use-package circe-notifications
    :commands enable-circe-notifications
    :init
    (add-hook 'circe-server-connected-hook #'enable-circe-notifications)
    :config
    (setq circe-notifications-backend "terminal-notifier")))

(defun cb-circe/init-circe-show-channels ()
  (use-package circe-show-channels
    :bind ("<f5>" . circe-show-channels)
    :config
    (progn
      (setq circe-show-channels-eyebrowse-window-config-number 1)
      (setq circe-show-channels-priority '(("#haskell" . 1))))))

;;; packages.el ends here
