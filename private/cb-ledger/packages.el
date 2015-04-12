(defvar cb-ledger-packages
  '(ledger-mode)
  "List of all packages to install and/or initialize. Built-in packages
which require an initialization must be listed explicitly in the list.")

(defvar cb-ledger-excluded-packages '()
  "List of packages to exclude.")

(defun cb-ledger/init-ledger-mode ()
  (use-package ledger-mode
    :init
    (add-to-list 'auto-mode-alist (cons "\\.ledger$" 'ledger-mode))
    :config
    (progn
      (setq ledger-master-file (f-join org-directory "accounts.ledger"))
      (setq ledger-post-account-alignment-column 2)
      (setq ledger-post-use-completion-engine :ido)
      (setq ledger-fontify-xact-state-overrides nil)
      (setq ledger-reports
            '(("assets" "ledger -f %(ledger-file) bal assets")
              ("balance" "ledger -f %(ledger-file) bal")
              ("register" "ledger -f %(ledger-file) reg")
              ("payee" "ledger -f %(ledger-file) reg @%(payee)")
              ("account" "ledger -f %(ledger-file) reg %(account)")
              ("net worth" "ledger -f %(ledger-file) bal ^assets ^liabilities")
              ("cash flow" "ledger -f %(ledger-file) bal ^income ^expenses")
              ("checking" "ledger -f %(ledger-file) --start-of-week friday -p 'this week' -r reg 'checking' --invert")))
      (setq ledger-report-format-specifiers
            '(("account" . cbledger:read-account)
              ("payee" . cbledger:read-payee)
              ("ledger-file" . ledger-report-ledger-file-format-specifier)
              ("value" . ledger-report-value-format-specifier)))

      (custom-set-faces
       '(ledger-occur-xact-face
         ((((background dark))  :background "#073642")
          (((background light)) :background "#eee8d5")))
       `(ledger-font-pending-face
         ((t (:foreground ,solarized-hl-orange))))
       `(ledger-font-payee-cleared-face
         ((t (:foreground ,solarized-hl-green))))
       `(ledger-font-payee-uncleared-face
         ((t (:foreground ,solarized-hl-orange))))
       `(ledger-font-posting-account-face
         ((t (:foreground ,solarized-hl-blue)))))

      (core/remap-face 'ledger-font-comment-face 'font-lock-comment-face)

      ;; Fix font lock issue in ledger reports
      (add-hook 'ledger-report-mode-hook 'font-lock-fontify-buffer))))
