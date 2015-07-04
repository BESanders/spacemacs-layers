;;; extensions.el --- cb-mu4e Layer extensions File for Spacemacs

;;; Commentary:

;; Mu4e mail client configuration. The accounts themselves are configured in my
;; personal config.
;;
;; There is a hard dependency between mu4e and the mu version so it is assumed
;; to have been installed via a package manager.
;;
;; On OS X:
;;
;;   brew install mu --with-emacs
;;

;;; Code:

(defconst cb-mu4e-pre-extensions '(mu4e mu4e-multi))

(defconst cb-mu4e-post-extensions '())

(eval-when-compile
  (require 'use-package nil t)
  (require 'dash)
  (require 'f))

;; Ensure extensions are on the load-path.
(--each (f-directories (f-join user-layers-directory "cb-mu4e/extensions"))
  (add-to-list 'load-path (f-slash it)))

(defun cb-mu4e/init-mu4e ()
  (use-package mu4e
    :load-path "/usr/local/share/emacs/site-lisp/mu4e/"
    :init
    (evil-leader/set-key "am" 'mu4e)
    :config
    (progn
      (setq mu4e-use-fancy-chars t)
      (setq mu4e-view-show-images t)
      (setq message-kill-buffer-on-exit t)

      ;; Use offlineimap to manage maildir.
      (setq mu4e-get-mail-command "offlineimap")

      ;; Save attachments to Downloads dir.
      (setq mu4e-attachment-dir (f-expand "~/Downloads"))

      ;; Disable signatures.
      (setq mu4e-compose-signature nil)
      (setq mu4e-compose-signature-auto-include nil)

      ;; Put quoted messages after signature.
      (setq message-forward-before-signature nil)

      ;; Update every 5 minutes.
      (setq mu4e-update-interval (* 60 5))

      ;; use imagemagick, if available
      (when (fboundp 'imagemagick-register-types)
        (imagemagick-register-types))

      ;; Render html emails using something reasonable.
      (setq mu4e-html2text-command
            (cond
             ((executable-find "textutil")
              "textutil -stdin -format html -convert txt -stdout")
             ((executable-find "w3m")
              "w3m -dump -cols 80 -T text/html")
             (t
              'html2text)))

      ;; Add option to view html message in a browser. `av` in view to activate
      (add-to-list 'mu4e-view-actions '("viewInBrowser" . mu4e-action-view-in-browser) t)

      ;; Define generic browser functions to support mu4e.
      (setq browse-url-browser-function 'eww-browse-url)
      (setq browse-url-mailto-function 'mu4e-multi-compose-new)
      )))

(defun cb-mu4e/init-mu4e-multi ()
  (use-package mu4e-multi
    :config
    (progn
      (global-set-key (kbd "C-x m") 'mu4e-multi-compose-new)
      ;; See `mu4e-multi-account-alist' in personal-config file for accounts
      ;; configuration (not on GitHub).
      (with-eval-after-load 'personal-config (mu4e-multi-enable)))))
