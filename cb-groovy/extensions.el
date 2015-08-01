;;; extensions.el --- cb-groovy Layer extensions File for Spacemacs
;;; Commentary:
;;; Code:

(defconst cb-groovy-pre-extensions '()
  "List of all extensions to load before the packages.")

(defconst cb-groovy-post-extensions '(super-smart-ops)
  "List of all extensions to load after the packages.")

(eval-when-compile
  (require 'use-package nil t))

(defun cb-groovy/init-super-smart-ops ()
  (use-package super-smart-ops
    :config
    (progn
      (super-smart-ops-configure-for-mode 'groovy-mode
        :custom
        `((":" . ,(super-smart-ops-make-smart-op ":" nil t))
          ("," . ,(super-smart-ops-make-smart-op "," nil t))))

      (super-smart-ops-configure-for-mode 'inferior-groovy-mode
        :custom
        `((":" . ,(super-smart-ops-make-smart-op ":" nil t))
          ("," . ,(super-smart-ops-make-smart-op "," nil t)))))))
