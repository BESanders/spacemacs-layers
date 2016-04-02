;;; packages.el --- cb-core Layer packages File for Spacemacs
;;; Commentary:
;;; Code:

(eval-when-compile
  (require 'use-package nil t)
  (require 's nil t)
  (require 'dash nil t)
  (require 'f nil t)
  (require 'noflet nil t))

(defconst cb-core-packages
  '(dash-functional
    diminish
    auto-revert
    hideshow
    helm
    aggressive-indent
    ag
    wgrep-ag
    alert
    helm-gtags
    world-time-mode
    iedit
    hl-line
    eldoc
    ido
    recentf
    neotree

    (cb-buffers :location local)
    (locate-key-binding :location local)
    (smart-ops :location local)
    (case :location local)
    (create-layer-local-package :location local)
    (indirect-region :location local)
    (remove-line-breaks :location local)
    (insert-timestamp :location local)))

(defun cb-core/user-config ()
  "This procedure should be called in `dotspacemacs/user-config'."
  (setq recentf-max-saved-items 1000)
  (setq bookmark-save-flag nil)

  ;; Set ace-window keys for dvorak.
  (setq aw-keys '(?a ?o ?e ?u ?i ?d ?h ?t ?n)))

(defun cb-core/init-dash-functional ()
  (use-package dash-functional
    :config (require 'dash-functional)))

(defun cb-core/post-init-diminish ()
  (diminish 'auto-fill-function " ≣"))

(defun cb-core/post-init-autorevert ()
  (diminish 'auto-revert-mode))

(defun cb-core/post-init-hideshow ()
  (diminish 'hs-minor-mode))

(defun cb-core/post-init-helm ()
  (require 'helm)
  (helm-autoresize-mode +1)
  (setq helm-buffers-fuzzy-matching t)
  (setq helm-recentf-fuzzy-match t)
  (setq helm-imenu-fuzzy-match t)

  (setq helm-locate-command
        (pcase system-type
          (`gnu/linux "locate -i -r %s")
          (`berkeley-unix "locate -i %s")
          (`windows-nt "es %s")
          (`darwin "mdfind -name %s %s | egrep -v '/Library/(Caches|Mail)/'")
          (t "locate %s")))

  (custom-set-faces
   `(helm-locate-finish
     ((t (:foreground ,solarized-hl-cyan))))
   '(helm-selection
     ((((background light)) :background "gray90" :foreground "black" :underline nil)
      (((background dark))  :background "black"  :foreground "white" :underline nil))))

  (defun helm-httpstatus ()
    "Helm command to display HTTP status codes."
    (interactive)
    (let ((source '((name . "HTTP STATUS")
                    (candidates . (("100 Continue") ("101 Switching Protocols")
                                   ("102 Processing") ("200 OK")
                                   ("201 Created") ("202 Accepted")
                                   ("203 Non-Authoritative Information") ("204 No Content")
                                   ("205 Reset Content") ("206 Partial Content")
                                   ("207 Multi-Status") ("208 Already Reported")
                                   ("300 Multiple Choices") ("301 Moved Permanently")
                                   ("302 Found") ("303 See Other")
                                   ("304 Not Modified") ("305 Use Proxy")
                                   ("307 Temporary Redirect") ("400 Bad Request")
                                   ("401 Unauthorized") ("402 Payment Required")
                                   ("403 Forbidden") ("404 Not Found")
                                   ("405 Method Not Allowed") ("406 Not Acceptable")
                                   ("407 Proxy Authentication Required") ("408 Request Timeout")
                                   ("409 Conflict") ("410 Gone")
                                   ("411 Length Required") ("412 Precondition Failed")
                                   ("413 Request Entity Too Large")
                                   ("414 Request-URI Too Large")
                                   ("415 Unsupported Media Type")
                                   ("416 Request Range Not Satisfiable")
                                   ("417 Expectation Failed") ("418 I'm a teapot")
                                   ("422 Unprocessable Entity") ("423 Locked")
                                   ("424 Failed Dependency") ("425 No code")
                                   ("426 Upgrade Required") ("428 Precondition Required")
                                   ("429 Too Many Requests")
                                   ("431 Request Header Fields Too Large")
                                   ("449 Retry with") ("500 Internal Server Error")
                                   ("501 Not Implemented") ("502 Bad Gateway")
                                   ("503 Service Unavailable") ("504 Gateway Timeout")
                                   ("505 HTTP Version Not Supported")
                                   ("506 Variant Also Negotiates")
                                   ("507 Insufficient Storage") ("509 Bandwidth Limit Exceeded")
                                   ("510 Not Extended")
                                   ("511 Network Authentication Required")))
                    (action . message))))
      (helm-other-buffer (list source) "*helm httpstatus*"))))

(defun cb-core/post-init-aggressive-indent ()

  (defun cb-core/turn-off-aggressive-indent-mode (&rest ignored)
    (aggressive-indent-mode -1))

  (with-eval-after-load 'aggressive-indent
    (add-to-list 'aggressive-indent-excluded-modes 'restclient-mode))

  (global-aggressive-indent-mode))

(defun cb-core/init-ag ()
  (use-package ag :commands ag))

(defun cb-core/init-wgrep-ag ()
  (use-package wgrep-ag
    :defer t))

(defun cb-core/init-alert ()
  (use-package alert
    :defer t
    :config
    (setq alert-default-style 'message)))

(defun cb-core/post-init-helm-gtags ()
  (setq helm-gtags-ignore-case t)
  (setq helm-gtags-auto-update t)
  (setq helm-gtags-use-input-at-cursor t)
  (setq helm-gtags-pulse-at-cursor t)
  (setq helm-gtags-prefix-key "\C-cg")
  (setq helm-gtags-suggested-key-mapping t)

  (with-eval-after-load 'pulse
    (core/remap-face 'pulse-highlight-face 'core/bg-flash)
    (core/remap-face 'pulse-highlight-start-face 'core/bg-flash))

  (with-eval-after-load 'helm-gtags
    (dolist (state '(normal insert))
      (evil-define-key state helm-gtags-mode-map
        (kbd "M-.") 'helm-gtags-dwim
        (kbd "M-,") 'helm-gtags-pop-stack))

    (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
    (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)))

(defun cb-core/init-world-time-mode ()
  (use-package world-time-mode
    :commands world-time-list
    :init
    (spacemacs/set-leader-keys "at" 'world-time-list)
    :config
    (progn
      (setq display-time-world-list '(("Pacific/Auckland" "NZT")
                                      ("UTC" "UTC")
                                      ("Europe/Berlin" "Germany")
                                      ("America/Los_Angeles" "Los Angeles")
                                      ("America/New_York" "New York")
                                      ("Australia/Sydney" "Sydney")))

      (evil-define-key 'normal world-time-table-mode-map (kbd "q") 'quit-window)
      (add-hook 'world-time-table-mode-hook 'hl-line-mode))))

(defun cb-core/init-smart-ops ()
  (use-package smart-ops
    :diminish smart-ops-mode
    :config
    (progn
      (smart-ops-global-mode)
      (evil-define-key 'insert smart-ops-mode-map (kbd "<backspace>") nil))))

(defun cb-core/post-init-iedit ()
  (custom-set-faces
   `(iedit-occurrence ((t (:background ,solarized-hl-orange :foreground "white"))))))

(defun cb-core/post-init-hl-line ()
  (global-hl-line-mode -1))

(defun cb-core/post-init-eldoc ()
  (setq eldoc-idle-delay 0.1))

(defun cb-core/init-case ()
  (use-package case))

(defun cb-core/init-locate-key-binding ()
  (use-package locate-key-binding
    :commands (locate-key-binding)))

(defun cb-core/post-init-recentf ()
  (setq recentf-save-file (concat spacemacs-cache-directory "recentf"))
  (setq recentf-max-menu-items 10)
  (setq recentf-keep '(file-remote-p file-readable-p))

  (defadvice recentf-cleanup (around hide-messages activate)
    "Do not message when cleaning up recentf list."
    (noflet ((message (&rest args))) ad-do-it))

  (with-eval-after-load 'recentf
    (setq recentf-exclude
          (-distinct (-concat recentf-exclude
                              (cb-core-regexp-quoted-ignored-dirs)
                              cb-vars-ignored-files-regexps)))
    (recentf-cleanup)))

(defun cb-core/post-init-ido ()
  (setq ido-use-filename-at-point 'guess)
  (add-to-list 'ido-ignore-buffers "\\*helm.*")
  (add-to-list 'ido-ignore-buffers "\\*Minibuf.*")
  (dolist (regexp cb-vars-ignored-files-regexps)
    (add-to-list 'ido-ignore-files regexp)))

(defun cb-core/init-cb-buffers ()
  (use-package cb-buffers
    :config
    (progn
      (bind-key* (kbd "C-<backspace>") 'cb-buffers-maybe-kill)
      (bind-key (kbd "C-c k b") 'cb-buffers-maybe-kill-all)

      (define-key prog-mode-map (kbd "M-q") #'cb-buffers-indent-dwim)
      (evil-define-key 'normal  prog-mode-map (kbd "M-q") #'cb-buffers-indent-dwim)

      (with-eval-after-load 'sgml-mode
        (evil-define-key 'normal  sgml-mode-map (kbd "M-q") #'cb-buffers-indent-dwim))

      (with-eval-after-load 'nxml-mode
        (evil-define-key 'normal nxml-mode-map (kbd "M-q") #'cb-buffers-indent-dwim)))))

(defun cb-core/post-init-neotree ()
  (use-package neotree
    :config
    (setq neo-theme 'arrow)))

(defun cb-core/init-create-layer-local-package ()
  (use-package create-layer-local-package
    :commands (create-layer-local-package)))

(defun cb-core/init-indirect-region ()
  (use-package indirect-region
    :commands (indirect-region)))

(defun cb-core/init-remove-line-breaks ()
  (use-package remove-line-breaks
    :commands (remove-line-breaks)))

(defun cb-core/init-insert-timestamp ()
  (use-package insert-timestamp
    :commands (insert-timestamp)
    :init (spacemacs/set-leader-keys "iT" #'insert-timestamp)))

;;; packages.el ends here
