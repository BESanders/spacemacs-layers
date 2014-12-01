(defvar cb-idris-packages
  '(
    ;; package cb-idriss go here
    idris-mode
    )
  "List of all packages to install and/or initialize. Built-in packages
which require an initialization must be listed explicitly in the list.")

(defvar cb-idris-excluded-packages '()
  "List of packages to exclude.")

;; For each package, define a function cb-idris/init-<package-cb-idris>
;;
;; (defun cb-idris/init-my-package ()
;;   "Initialize my package"
;;   )
;;
;; Often the body of an initialize function uses `use-package'
;; For more info on `use-package', see readme:
;; https://github.com/jwiegley/use-package

(defun cb-idris/init-idris-mode ()
  (use-package idris-mode
    :mode "\\.idr\\'"
    :init
    (progn
      (add-to-list 'completion-ignored-extensions ".ibc")

      (defvar idris-mode-hook
        '(turn-on-idris-simple-indent
          idris-enable-clickable-imports
          turn-on-eldoc-mode
          idris-define-loading-keys
          idris-define-docs-keys
          idris-define-editing-keys
          idris-define-general-keys
          idris-define-ipkg-keys
          idris-define-ipkg-opening-keys
          idris-define-evil-keys))

      )
    :config
    (progn
      (setq idris-warnings-printing 'warnings-repl)
      (setq idris-repl-animate nil)
      (setq idris-repl-prompt-style 'long)

      (put 'idris-mode 'tab-width 2)
      (put 'idris-mode 'evil-shift-width 2)

      (add-to-list 'face-remapping-alist '(idris-semantic-type-face     . font-lock-type-face))
      (add-to-list 'face-remapping-alist '(idris-semantic-data-face     . default))
      (add-to-list 'face-remapping-alist '(idris-semantic-function-face . font-lock-function-name-face))
      (add-to-list 'face-remapping-alist '(idris-semantic-bound-face    . font-lock-variable-name-face))
      (add-to-list 'face-remapping-alist '(idris-semantic-implicit-face . font-lock-comment-face))
      (add-to-list 'face-remapping-alist '(idris-repl-output-face       . compilation-info))

      (add-to-list 'font-lock-keywords-alist
                   '(idris-mode
                     ((("^ *record\\>" . font-lock-keyword-face)))))


      ;; Advices

      (defadvice idris-mode (before start-process activate)
        "Automatically run an idris process."
        (unless idris-process
          (idris-run))))))
