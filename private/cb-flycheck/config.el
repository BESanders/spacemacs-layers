;;; Hide tmp file paths from error output

(defconst cb-flycheck--src-file-rx
  (rx bol (+ space) (? "(bound ") "at /" (* nonl) eol))

(defun cb-flycheck--strip-filepath (str)
  (->> (s-split "\n" str)
       (--remove (s-matches? cb-flycheck--src-file-rx it))
       (s-join "\n")))

(defun cb-flycheck-strip-files-in-messages (errors)
  (dolist (err errors)
    (let ((message (cb-flycheck--strip-filepath (flycheck-error-message err))))
      (setf (flycheck-error-message err) message)))
  errors)

(with-eval-after-load 'flycheck
  (put 'haskell-ghc
       'flycheck-error-filter
       (lambda (errors)
         (-> errors
             flycheck-dedent-error-messages
             cb-flycheck-strip-files-in-messages
             flycheck-sanitize-errors))))

(with-eval-after-load 'flycheck-liquid
  (put 'haskell-liquid
       'flycheck-error-filter
       (lambda (errors)
         (-> errors
             flycheck-dedent-error-messages
             cb-flycheck-strip-files-in-messages
             flycheck-sanitize-errors))))
