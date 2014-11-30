(defvar cb-yasnippet-pre-extensions
  '(
    ;; pre extension cb-yasnippets go here
    )
  "List of all extensions to load before the packages.")

(defvar cb-yasnippet-post-extensions
  '(
    ;; post extension cb-yasnippets go here
    )
  "List of all extensions to load after the packages.")

;; For each extension, define a function cb-yasnippet/init-<extension-cb-yasnippet>
;;
;; (defun cb-yasnippet/init-my-extension ()
;;   "Initialize my extension"
;;   )
;;
;; Often the body of an initialize function uses `use-package'
;; For more info on `use-package', see readme:
;; https://github.com/jwiegley/use-package
