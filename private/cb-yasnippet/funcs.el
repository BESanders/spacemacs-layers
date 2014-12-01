;;; Utilities

(defmacro yas-with-field-restriction (&rest body)
  "Narrow the buffer to the current active field and execute BODY.
If no field is active, no narrowing will take place."
  (declare (indent 0))
  `(save-restriction
     (when (yas/current-field)
       (narrow-to-region (yas/beginning-of-field) (yas/end-of-field)))
     ,@body))

(defun yas/bol? ()
  "Non-nil if point is on an empty line or at the first word.
The rest of the line must be blank."
  (s-matches? (rx bol (* space) (* word) (* space) eol)
              (buffer-substring (line-beginning-position) (line-end-position))))

(defun yas/msg (fmt &rest args)
  "Like `message', but returns the empty string.
Embed in elisp blocks to trigger messages within snippets."
  (apply 'message (s-prepend "[yas] " fmt) args)
  "")

(defun yas-insert-first-snippet (predicate)
  "Choose a snippet to expand according to PREDICATE."
  (setq yas--condition-cache-timestamp (current-time))
  (let ((yas-buffer-local-condition 'always))
    (-if-let (yas--current-template
              (-first predicate (yas--all-templates (yas--get-snippet-tables))))
        (let ((where (if (region-active-p)
                         (cons (region-beginning) (region-end))
                       (cons (point) (point)))))
          (yas-expand-snippet (yas--template-content yas--current-template)
                              (car where)
                              (cdr where)
                              (yas--template-expand-env yas--current-template)))
      (error "No snippet matching predicate"))))

(defun yas/current-field ()
  "Return the current active field."
  (and (boundp 'yas--active-field-overlay)
       yas--active-field-overlay
       (overlay-buffer yas--active-field-overlay)
       (overlay-get yas--active-field-overlay 'yas--field)))

(defun yas/beginning-of-field ()
  (-when-let (field (yas/current-field))
    (marker-position (yas--field-start field))))

(defun yas/end-of-field ()
  (-when-let (field (yas/current-field))
    (marker-position (yas--field-end field))))

(defun yas/current-field-text ()
  "Return the text in the active snippet field."
  (-when-let (field (yas/current-field))
    (yas--field-text-for-display field)))

(defun yas/clear-blank-field ()
  "Clear the current field if it is blank."
  (-when-let* ((beg (yas/beginning-of-field))
               (end (yas/end-of-field))
               (str (yas/current-field-text)))
    (when (s-matches? (rx bos (+ space) eos) str)
      (delete-region beg end)
      t)))

(defun yas/maybe-goto-field-end ()
  "Move to the end of the current field if it has been modified."
  (-when-let (field (yas/current-field))
    (when (and (yas--field-modified-p field)
               (yas--field-contains-point-p field))
      (goto-char (yas/end-of-field)))))


;;; Elisp

(defun yas/find-identifier-prefix ()
  "Find the commonest identifier prefix in use in this buffer."
  (let ((ns-separators (rx (or ":" "--" "/"))))
    (->> (buffer-string)
      ;; Extract the identifiers from declarations.
      (s-match-strings-all
       (rx bol (* space)
           "(" (? "cl-") (or "defun" "defmacro" "defvar" "defconst")
           (+ space)
           (group (+ (not space)))))
      ;; Find the commonest prefix.
      (-map 'cadr)
      (--filter (s-matches? ns-separators it))
      (--map (car (s-match (rx (group (* nonl) (or ":" "--" "/"))) it)))
      (-group-by 'identity)
      (-max-by (-on '>= 'length))
      (car))))

(defun yas/find-group-for-snippet ()
  "Find the first group defined in the current file,
falling back to the file name sans extension."
  (or
   (cadr (s-match (rx "(defgroup" (+ space) (group (+ (not
                                                       space))))
                  (buffer-string)))
   (cadr (s-match (rx ":group" (+ space) "'" (group (+ (any "-" alnum))))
                  (buffer-string)))
   (f-no-ext (f-filename buffer-file-name))))

(defun yas/simplify-arglist (text)
  "Return a simplified docstring of arglist TEXT."
  (->> (ignore-errors
         (read (format "(%s)" text)))
    (--keep
     (ignore-errors
       (cond
        ((listp it)
         (-first (lambda (x)
                   (and (symbolp x)
                        (not (s-starts-with? "&" (symbol-name x)))))
                 it))
        ((symbolp it) it))))
    (--remove (s-starts-with? "&" (symbol-name it)))))

(defun yas/cl-arglist? (text)
  "Non-nil if TEXT is a Common Lisp arglist."
  (let ((al (ignore-errors (read (format "(%s)" text)))))
    (or (-any? 'listp al)
        (-intersection al '(&key &allow-other-keys &body)))))

(defun yas/defun-form-for-arglist (text)
  "Return either 'defun or 'cl-defun depending on whether TEXT
is a Common Lisp arglist."
  (if (yas/cl-arglist? text) 'cl-defun 'defun))

(defun yas/defmacro-form-for-arglist (text)
  "Return either 'defmacro or 'cl-defmacro depending on whether TEXT
is a Common Lisp arglist."
  (if (yas/cl-arglist? text) 'cl-defmacro 'defmacro))

(defun yas/process-docstring (text)
  "Format a function docstring for a snippet.
TEXT is the content of the docstring."
  (let ((docs (->> (yas/simplify-arglist text)
                (--map (s-upcase (symbol-name it)))
                (s-join "\n\n"))))
    (unless (s-blank? docs)
      (concat "\n\n" docs))))

(defun yas/find-prefix-for-use-package ()
  "Infer the name of the package being configured by the name of the enclosing defun."
  (save-excursion
    (search-backward-regexp (rx "defun" (? "*") (+ space) (group (+ anything)) "/init-")
                            nil t)
    (match-string 1)))

(defun yas/find-ident-for-use-package ()
  "Infer the name of the package being configured by the name of the enclosing defun."
  (save-excursion
    (search-backward-regexp (rx "defun" (? "*") (+ space) (+ anything) "/init-" (group (+ (not space))))
                            nil t)
    (match-string 1)))

;;; Editing commands

(defun yas//reload-all ()
  (interactive)
  (yas-recompile-all)
  (yas-reload-all))

(defun yas/space ()
  "Clear and skip this field if it is unmodified. Otherwise insert a space."
  (interactive "*")
  (let ((field (yas/current-field)))
    (cond ((and field
                (not (yas--field-modified-p field))
                (eq (point) (marker-position (yas--field-start field))))
           (yas--skip-and-clear field)
           (yas-next-field 1))
          (t
           (insert " ")))))

(defun yas/backspace ()
  "Clear the current field if the current snippet is unmodified.
Otherwise delete backwards."
  (interactive "*")
  (let ((field (yas/current-field)))
    (cond ((and field
                (not (yas--field-modified-p field))
                (eq (point) (marker-position (yas--field-start field))))
           (yas--skip-and-clear field)
           (yas-next-field 1))
          (smartparens-mode
           (call-interactively 'sp-backward-delete-char))
          (t
           (call-interactively 'backward-delete-char)))))


;;; Utilities for working around internal yasnippet errors

(defun yas//other-buffer-major-mode ()
  "Guess the mode to use for a snippet.
Use the mode of the last editing buffer."
  (with-current-buffer (-first (-not 'minibufferp) (cdr (buffer-list)))
    major-mode))

(defun yas//new-snippet? (template)
  "Return whether TEMPLATE should be saved as a new snippet.

Only offer to save this if it looks like a library or new
snippet (loaded from elisp, from a dir in `yas-snippet-dirs'which
is not the first, or from an unwritable file)."
  (or (not (yas--template-file template))
      (not (f-writable? (yas--template-file template)))
      (and (listp yas-snippet-dirs)
           (< 1 (length yas-snippet-dirs))
           (not (f-child-of? (yas--template-file template)
                             (car yas-snippet-dirs))))))

(defun yas//create-dir-for-template (template)
  (-when-let* ((snippet-dirs (yas--guess-snippet-directories (yas--template-table template))))
    (yas--make-directory-maybe (car snippet-dirs))))

(defun yas//snippet-file-name (template)
  (-if-let (file (yas--template-file template))
      (f-filename file)
    (yas--template-name template)))

(defun yas//maybe-write-new-template (template)
  (cl-assert template () "Attempting to access null yas template")
  (when (yas//new-snippet? template)
    (-when-let* ((snippet-dir (yas//create-dir-for-template template))
                 (file-name (yas//snippet-file-name template)))
      (write-file (f-join snippet-dir file-name))
      (setf (yas--template-file template) (buffer-file-name)))))

;;; Scala

(defun yas/scala-find-case-class-parent ()
  (save-excursion
    (if (search-backward-regexp
         (rx (or
              (and bol (* space)
                   (or (and (? "abstract" (+ space)) "class")
                       "trait")
                   (+ space) (group-n 1 (+ alnum)))
              (and bol (* space)
                   "case" (+ space) "class" (* anything) space
                   "extends" (+ space) (group-n 1 (+ alnum)) (* space) eol)))
         nil t)
        (match-string 1)
      "")))
