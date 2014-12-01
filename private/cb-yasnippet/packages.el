(defvar cb-yasnippet-packages
  '(
    yasnippet
    )
  "List of all packages to install and/or initialize. Built-in packages
which require an initialization must be listed explicitly in the list.")

(defvar cb-yasnippet-excluded-packages '()
  "List of packages to exclude.")

;; For each package, define a function cb-yasnippet/init-<package-cb-yasnippet>
;;
;; (defun cb-yasnippet/init-my-package ()
;;   "Initialize my package"
;;   )
;;
;; Often the body of an initialize function uses `use-package'
;; For more info on `use-package', see readme:
;; https://github.com/jwiegley/use-package

(require 'f)

(defun cb-yasnippet/init-yasnippet ()
  (use-package yasnippet
    :init
    (progn
      (setq yas-snippet-dirs (list (concat spacemacs-private-directory "cb-yasnippet/snippets")))
      (add-hook 'prog-mode-hook 'yas-minor-mode)
      (add-hook 'text-mode-hook 'yas-minor-mode)
      (yas-global-mode +1))
    :config
    (progn
      (setq yas-prompt-functions '(yas-ido-prompt))
      (setq yas-wrap-around-region t)
      (setq yas-verbosity 0)

      (custom-set-faces
       '(yas-field-highlight-face
         ((((background light)) :background "lightgreen")
          (((background dark)) :background "green4" :foreground "grey80"))))

      (add-hook 'snippet-mode-hook (lambda () (setq-local require-final-newline nil)))

      ;; Advise editing commands.
      ;;
      ;; Pressing SPC in an unmodified field will clear it and switch to the next.
      ;;
      ;; Pressing S-TAB to go to last field will place point at the end of the field.

      (defadvice yas-next-field (before clear-blank-field activate)
        (yas/clear-blank-field))

      (defadvice yas-prev-field (before clear-blank-field activate)
        (yas/clear-blank-field))

      (defadvice yas-next-field (after goto-field-end activate)
        (yas/maybe-goto-field-end)
        (evil-insert-state))

      (defadvice yas-prev-field (after goto-field-end activate)
        (yas/maybe-goto-field-end)
        (evil-insert-state))

      ;; FIX: yasnippet often errors when trying to save existing snippets.

      (defun yas--read-table ()
        "Ask user for a snippet table, help with some guessing."
        (let ((modes (-distinct (-snoc (yas--compute-major-mode-and-parents (buffer-file-name))
                                       (yas//other-buffer-major-mode)))))
          (intern (completing-read "Choose or enter a mode: " modes))))

      (defun yas-load-snippet-buffer-and-close (table &optional _)
        "Load the snippet with `yas-load-snippet-buffer', possibly
  save, then `quit-window' if saved.

If the snippet is new, ask the user whether (and where) to save
it. If the snippet already has a file, just save it.

Don't use this from a Lisp program, call `yas-load-snippet-buffer'
and `kill-buffer' instead."
        (interactive (list (yas--read-table) nil))
        (yas-load-snippet-buffer table t)
        (noflet ((whitespace-cleanup (&rest _)))
          (yas//maybe-write-new-template yas--editing-template)
          (save-buffer)
          (quit-window t))))))
