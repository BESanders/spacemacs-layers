(defvar cb-core-pre-extensions
  '(
    ;; pre extension cores go here
    super-smart-ops
    file-template
    recentf
    )
  "List of all extensions to load before the packages.")

(defvar cb-core-post-extensions
  '(
    ;; post extension cores go here
    ido
    )
  "List of all extensions to load after the packages.")

;; For each extension, define a function core/init-<extension-core>
;;
;; (defun core/init-my-extension ()
;;   "Initialize my extension"
;;   )
;;
;; Often the body of an initialize function uses `use-package'
;; For more info on `use-package', see readme:
;; https://github.com/jwiegley/use-package

(defun core/init-super-smart-ops ()
  (use-package super-smart-ops))

(defun core/init-file-template ()
  (use-package file-template
    :config
    (progn
      (require 'f)

      (setq core/file-templates-dir (f-join spacemacs-private-directory
                                            "cb-core/extensions/file-template"
                                            "templates"))
      (setq file-template-insert-automatically t)
      (setq file-template-paths (list core/file-templates-dir))
      (setq file-template-mapping-alist
            (->> (f-files core/file-templates-dir)
              (-map 'f-filename)
              (--map (cons (format "\\.%s$" (f-ext it)) it))))

      (add-hook 'find-file-not-found-hooks 'file-template-find-file-not-found-hook t)
      (add-hook 'file-template-insert-hook 'core/reset-buffer-undo-history))))

(defun core/init-ido ()
  (use-package ido
    :config
    (progn
      (setq ido-use-filename-at-point 'guess)
      (add-to-list 'ido-ignore-buffers "\\*helm.*")
      (add-to-list 'ido-ignore-buffers "\\*Minibuf.*")
      (add-to-list 'ido-ignore-files "flycheck_")
      (add-to-list 'ido-ignore-files "\\.swp")
      (add-to-list 'ido-ignore-files "\\.DS_Store"))))

(defun cb-core/init-recentf ()
  (use-package recentf
    :commands recentf-mode
    :config
    (progn
      (setq recentf-save-file (concat spacemacs-cache-directory "recentf"))
      (setq recentf-max-saved-items 50)
      (setq recentf-max-menu-items 10)
      (setq recentf-keep '(file-remote-p file-readable-p))
      (setq recentf-exclude
            '("\\.elc$"
              "TAGS"
              "\\.gz$"
              "#$"
              "/elpa/"
              "/tmp/"
              "/temp/"
              "/snippets/"
              ".emacs.d/url/"
              "/\\.git/"
              "/Emacs.app/"
              "/var/folders/"
              "^/?sudo"
              "\\.bbdb"
              "\\.newsrc"
              "/gnus$"
              "/gnus.eld$"
              "\\.ido\\.last"
              "\\.org-clock-save\\.el$"))

      (defadvice recentf-cleanup (around hide-messages activate)
        "Do not message when cleaning up recentf list."
        (noflet ((message (&rest args))) ad-do-it)))))
