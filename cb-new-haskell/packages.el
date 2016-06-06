;;; packages.el --- cb-new-haskell layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
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
;; added to `cb-new-haskell-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `cb-new-haskell/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `cb-new-haskell/pre-init-PACKAGE' and/or
;;   `cb-new-haskell/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(eval-when-compile
  (require 'use-package nil t))

(defconst cb-new-haskell-packages
  '(haskell-mode
    smart-ops
    aggressive-indent
    indent-dwim
    intero
    llvm-mode

    (ghc-dump :location local)
    (haskell-flyspell :location local)
    (haskell-ghc-opts :location local)
    (haskell-imports :location local)
    (haskell-pragmas :location local)
    (haskell-ret :location local)
    (haskell-unicode :location local)
    (haskell-autoinsert :location local)
    (cb-haskell-alignment :location local)
    (haskell-flycheck-holes :location local))
  "The list of Lisp packages required by the cb-new-haskell layer.

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

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

(defun cb-new-haskell/init-haskell-mode ()
  (use-package haskell-mode
    :defer t
    :config
    (progn
      (setq haskell-process-type 'stack-ghci)
      (setq haskell-process-use-presentation-mode t)
      (setq haskell-interactive-mode-eval-mode 'haskell-mode)
      (setq haskell-interactive-mode-scroll-to-bottom t)
      (setq haskell-interactive-popup-errors t)
      (setq haskell-interactive-prompt "\nλ> ")
      (setq haskell-process-show-debug-tips t)
      (setq haskell-stylish-on-save t)

      ;; Use 4 space indentation style.

      (setq haskell-indentation-layout-offset 4)
      (setq haskell-indentation-starter-offset 2)
      (setq haskell-indentation-where-pre-offset 2)
      (setq haskell-indentation-where-post-offset 2)
      (setq haskell-indentation-left-offset 4)
      (setq haskell-indent-spaces 4)

      (defun cb-new-haskell/set-indentation-step ()
        (with-no-warnings (setq evil-shift-width 4))
        (setq tab-width 4))

      (add-hook 'haskell-mode-hook #'cb-new-haskell/set-indentation-step)

      ;; Make 3rd-party tools aware of common syntax extensions.

      (setq haskell-language-extensions
            '("-XUnicodeSyntax" "-XLambdaCase" "-XRankNTypes"))


      ;; Ignore generated files.

      (add-to-list 'completion-ignored-extensions ".hi")
      (add-to-list 'completion-ignored-extensions ".gm")


      ;; Disable haskell-interactive-mode for org src blocks.

      (defun cb-new-haskell/maybe-haskell-interactive-mode ()
        (unless (bound-and-true-p org-src-mode)
          (interactive-haskell-mode)))

      (add-hook 'haskell-mode-hook #'cb-new-haskell/maybe-haskell-interactive-mode)

      ;; Disable some faces.

      (custom-set-faces
       '(haskell-interactive-face-compile-error ((t (:foreground nil))))
       '(haskell-operator-face ((t :italic nil))))

      ;; Set keybindings.

      (evil-define-key 'normal haskell-mode-map (kbd "<backtab>") #'haskell-indentation-indent-backwards)
      (evil-define-key 'normal haskell-mode-map (kbd "TAB") #'haskell-indentation-indent-line)
      (define-key haskell-mode-map (kbd "<backtab>") #'haskell-indentation-indent-backwards)
      (define-key haskell-mode-map (kbd "TAB")       #'haskell-indentation-indent-line)
      (define-key haskell-mode-map (kbd "M-P")       #'flymake-goto-prev-error)
      (define-key haskell-mode-map (kbd "M-N")       #'flymake-goto-next-error)
      (define-key haskell-mode-map (kbd "C-,")       #'haskell-move-nested-left)
      (define-key haskell-mode-map (kbd "C-.")       #'haskell-move-nested-right)
      (define-key haskell-mode-map (kbd "C-c C-d")   #'haskell-w3m-open-haddock)
      (define-key haskell-mode-map (kbd "C-c C-f")   #'haskell-cabal-visit-file)
      (define-key haskell-mode-map (kbd "C-c C-h")   #'haskell-hoogle)))

  (use-package haskell-interactive-mode
    :after haskell-mode
    :config
    (progn
      (define-key haskell-interactive-mode-map (kbd "C-c C-h") #'haskell-hoogle)
      (evil-define-key 'normal haskell-error-mode-map (kbd "q") #'quit-window)))

  (use-package haskell-cabal
    :after haskell-mode
    :config
    (define-key haskell-cabal-mode-map (kbd "C-c C-k") #'haskell-interactive-mode-clear))

  (use-package haskell-debug
    :after haskell-mode
    :config
    (progn
      (add-hook 'haskell-debug-mode-hook #'flyspell-mode-off)

      (with-no-warnings
        (evilified-state-evilify-map haskell-debug-mode-map
          :mode haskell-debug-mode
          :bindings
          (kbd "n") #'haskell-debug/next
          (kbd "N") #'haskell-debug/previous
          (kbd "p") #'haskell-debug/previous
          (kbd "q") #'quit-window))))

  (use-package haskell-presentation-mode
    :after haskell-mode
    :config
    (evil-define-key 'normal haskell-presentation-mode-map (kbd "q") #'quit-window)))

(defun cb-new-haskell/post-init-aggressive-indent ()
  (with-eval-after-load 'aggressive-indent
    (with-no-warnings
      (add-to-list 'aggressive-indent-excluded-modes 'haskell-interactive-mode))))

(defun cb-new-haskell/init-intero ()
  (use-package intero
    :after haskell-mode
    :config
    (progn
      (add-hook 'haskell-mode-hook #'intero-mode)

      (evil-define-key 'normal intero-mode-map (kbd "M-.") #'intero-goto-definition)
      (evil-define-key 'normal intero-mode-map (kbd "M-,") #'pop-global-mark)
      (define-key intero-mode-map (kbd "M-.") #'intero-goto-definition)
      (define-key intero-mode-map (kbd "M-,") #'pop-global-mark)
      (spacemacs/set-leader-keys-for-major-mode 'haskell-mode "t" #'intero-targets))))

(defun cb-new-haskell/post-init-smart-ops ()

  (defun cb-new-haskell/reformat-comment-at-point ()
    (-when-let ((&plist :beg beg :end end :op op) (sp-get-enclosing-sexp))
      (when (and (equal op "{")
                 (s-matches? (rx bos "{" (* (any "-" space)) "}" eos)
                             (buffer-substring beg end)))
        (goto-char beg)
        (delete-region beg end)
        (insert "{- ")
        (save-excursion (insert " -}")))))

  (defun cb-new-haskell/reformat-pragma-at-point ()
    (-when-let ((&plist :beg beg :end end :op op) (sp-get-enclosing-sexp))
      (when (and (equal op "{")
                 (s-matches? (rx bos "{" (* (any "-" space "#")) "}" eos)
                             (buffer-substring beg end)))
        (goto-char beg)
        (delete-region beg end)
        (insert "{-# ")
        (save-excursion (insert " #-}")))))

  (defun cb-new-haskell/indent-if-in-exports ()
    (when (ignore-errors (s-matches? "ExportSpec" (elt (shm-current-node) 0)))
      (haskell-indentation-indent-line)))

  (defconst cb-new-haskell/smart-ops
    (-flatten-n 1
                (list
                 (smart-ops "." :bypass? t)
                 (smart-ops "->" "=>")
                 (smart-ops "$" "=" "~" "^" ":" "?")
                 (smart-ops "^." ".~" "^~" "%~" :pad-before t :pad-after t)
                 (smart-op ";"
                           :pad-before nil :pad-after t)
                 (smart-ops ","
                            :pad-before nil :pad-after t
                            :action
                            #'cb-new-haskell/indent-if-in-exports)
                 (smart-op "-"
                           :action #'cb-new-haskell/reformat-comment-at-point)
                 (smart-op "#"
                           :pad-before nil :pad-after nil
                           :action #'cb-new-haskell/reformat-pragma-at-point)
                 (smart-ops-default-ops))))

  (define-smart-ops-for-mode 'haskell-mode
    cb-new-haskell/smart-ops)

  (define-smart-ops-for-mode 'haskell-interactive-mode
    (smart-op ":" :pad-unless (lambda (_) (haskell-interactive-at-prompt)))
    cb-new-haskell/smart-ops)

  ;; HACK: Enable smart ops for `haskell-mode' manually, since it is not derived
  ;; from `prog-mode'.
  (add-hook 'haskell-mode-hook #'smart-ops-mode))

(defun cb-new-haskell/post-init-indent-dwim ()
  (use-package indent-dwim
    :config
    (progn
      (autoload 'haskell-unicode-apply-to-buffer "haskell-unicode")

      (defun cb-new-haskell/format-dwim ()
        "Reformat the buffer."
        (interactive "*")
        (hindent/reformat-decl)
        (haskell-mode-stylish-buffer)
        (haskell-unicode-apply-to-buffer))

      (add-to-list 'indent-dwim-commands-alist '(haskell-mode . cb-new-haskell/format-dwim)))))

(defun cb-new-haskell/init-llvm-mode ()
  (use-package llvm-mode))

(defun cb-new-haskell/init-ghc-dump ()
  (use-package ghc-dump
    :config
    (progn
      (spacemacs/set-leader-keys-for-major-mode 'haskell-mode "D" #'ghc-dump-popup)
      (bind-key "q" #'cb-buffers-maybe-kill ghc-dump-popup-mode-map))))

(defun cb-new-haskell/init-haskell-flyspell ()
  (use-package haskell-flyspell
    :functions (haskell-flyspell-init)
    :init (add-hook 'haskell-mode-hook #'haskell-flyspell-init)))

(defun cb-new-haskell/init-haskell-ghc-opts ()
  (use-package haskell-ghc-opts
    :functions (haskell-ghc-opts-init)
    :init (add-hook 'haskell-mode-hook #'haskell-ghc-opts-init)))

(defun cb-new-haskell/init-haskell-imports ()
  (use-package haskell-imports
    :functions (haskell-imports-init)
    :init (add-hook 'haskell-mode-hook #'haskell-imports-init)))

(defun cb-new-haskell/init-haskell-pragmas ()
  (use-package haskell-pragmas
    :functions (haskell-pragmas-init)
    :init (add-hook 'haskell-mode-hook #'haskell-pragmas-init)))

(defun cb-new-haskell/init-haskell-unicode ()
  (use-package haskell-unicode
    :functions haskell-unicode-init
    :init (add-hook 'haskell-mode-hook #'haskell-unicode-init)))

(defun cb-new-haskell/init-haskell-autoinsert ()
  (use-package haskell-autoinsert
    :functions (haskell-autoinsert-init)
    :config (haskell-autoinsert-init)))

(defun cb-new-haskell/init-cb-haskell-alignment ()
  (use-package cb-haskell-alignment
    :functions cb-haskell-alignment-init
    :config
    (add-hook 'haskell-mode-hook #'cb-haskell-alignment-init)))

(defun cb-new-haskell/init-haskell-ret ()
  (use-package haskell-ret
    :functions haskell-ret-init
    :init (add-hook 'haskell-mode-hook #'haskell-ret-init)))

(defun cb-new-haskell/init-haskell-flycheck-holes ()
  (use-package haskell-flycheck-holes
    :after (haskell-mode flycheck)
    :config
    (add-hook 'haskell-mode-hook #'haskell-flycheck-holes-init)))

;;; packages.el ends here
