;;; packages.el --- cb-ledger Layer packages File for Spacemacs
;;; Commentary:
;;; Code:

(defconst cb-ledger-packages
  '(ledger-mode
    (cb-ledger-reports :location local))
  "List of all packages to install and/or initialize. Built-in packages
which require an initialization must be listed explicitly in the list.")

(defun cb-ledger/user-config ()
  ;; Set this keybinding late so that Spacemacs does not clobber it.
  (spacemacs/set-leader-keys "o$" #'cb-ledger-goto-ledger-file))

(eval-when-compile
  (require 'use-package nil t))

(defun cb-ledger/post-init-ledger-mode ()
  (use-package ledger-mode
    :mode ("\\.ledger$" . ledger-mode)
    :config
    (progn
      (setq ledger-master-file (f-join org-directory "accounts.ledger"))
      (setq ledger-post-account-alignment-column 2)
      (setq ledger-post-use-completion-engine :ido)
      (setq ledger-fontify-xact-state-overrides nil)

      ;; Faces and font-locking

      (defface ledger-date
        `((t :inherit org-date :underline nil :foreground ,solarized-hl-cyan))
        "Face for dates at start of transactions."
        :group 'ledger-faces)

      (defface ledger-periodic-header
        `((t :foreground ,solarized-hl-violet :bold t))
        "Face for the header for periodic transactions."
        :group 'ledger-faces)

      (defface ledger-year-line
        `((t :foreground ,solarized-hl-violet))
        "Face for year declarations."
        :group 'ledger-faces)

      (defface ledger-report-negative-amount
        `((t (:foreground ,solarized-hl-red)))
        "Face for negative amounts in ledger reports."
        :group 'ledger-faces)

      (font-lock-add-keywords
       'ledger-mode
       `((,(rx bol (+ (any digit "=" "/"))) . 'ledger-date)
         (,(rx bol "~" (* nonl)) . 'ledger-periodic-header)
         (,(rx bol "year" (+ space) (+ digit) (* space) eol) . 'ledger-year-line)))

      (font-lock-add-keywords
       'ledger-report-mode
       `((,(rx "$" (* space) "-" (+ digit) (? "." (+ digit))) . 'ledger-report-negative-amount)
         (,(rx (+ digit) "-" (= 3 alpha) "-" (+ digit)) . 'ledger-date)))

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
      (add-hook 'ledger-report-mode-hook 'font-lock-fontify-buffer)

      ;;; Keybindings

      (define-key ledger-mode-map (kbd "C-c C-c") #'ledger-report)
      (define-key ledger-mode-map (kbd "M-RET")   #'ledger-toggle-current-transaction)
      (define-key ledger-mode-map (kbd "M-q")     #'cb-ledger-format-buffer)
      (define-key ledger-mode-map (kbd "C-c C-.") #'cb-ledger-insert-timestamp)

      (evil-define-key 'normal ledger-report-mode-map (kbd "q") #'kill-buffer-and-window))))

(defun cb-ledger/init-cb-ledger-reports ()
  (use-package cb-ledger-reports
    :config
    (progn
      (setq cb-ledger-reports-income-payee-name "Income:Movio")

      (setq ledger-report-format-specifiers
            '(("ledger-file" . ledger-report-ledger-file-format-specifier)
              ("last-payday" . cb-ledger-reports-last-payday)
              ("prev-pay-period" . cb-ledger-reports-previous-pay-period)
              ("payee" . ledger-report-payee-format-specifier)
              ("account" . ledger-report-account-format-specifier)
              ("tagname" . ledger-report-tagname-format-specifier)
              ("tagvalue" . ledger-report-tagvalue-format-specifier)))

      (setq ledger-reports
            '(("assets" "ledger -f %(ledger-file) bal assets")
              ("balance" "ledger -f %(ledger-file) bal")
              ("register" "ledger -f %(ledger-file) reg")
              ("payee" "ledger -f %(ledger-file) reg @%(payee)")
              ("account" "ledger -f %(ledger-file) reg %(account)")
              ("net worth" "ledger -f %(ledger-file) bal ^assets ^liabilities")
              ("cash flow" "ledger -f %(ledger-file) bal ^income ^expenses")
              ("this week" "ledger -f %(ledger-file) -p 'this week' -r reg 'checking' --invert")
              ("this month" "ledger -f %(ledger-file) -p 'this month' -r reg 'checking' --invert")
              ("reg since payday" "ledger -f %(ledger-file) -b %(last-payday) -r reg 'checking' --invert")
              ("bal since payday" "ledger -f %(ledger-file) -b %(last-payday) -r bal 'checking' --invert")

              ("reg last pay period" "ledger -f %(ledger-file) -p %(prev-pay-period) -r reg 'checking' --invert")
              ("bal last pay period" "ledger -f %(ledger-file) -p %(prev-pay-period) -r bal 'checking' --invert"))))))
