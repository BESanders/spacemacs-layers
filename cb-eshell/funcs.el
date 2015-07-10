;;; funcs.el --- Eshell functions  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'dash)
(require 's)

;;; Toggle display of Eshell

(defun cb-eshell-bring (&optional new)
  "Display an eshell buffer, creating a new one if needed.
With prefix argument ARG, always create a new shell."
  (interactive "P")
  (cond
   (new
    (cb-eshell--new))
   ((derived-mode-p 'eshell-mode)
    (cb-eshell--hide))
   ((cb-eshell--buffer)
    (cb-eshell--show))
   (t
    (cb-eshell--new))))

(defun cb-eshell--hide ()
  (let ((reg (cb-eshell--mk-register-name)))
    (if (get-register reg)
        (or (ignore-errors (jump-to-register reg t) t)
            (bury-buffer))
      (bury-buffer)
      (when (< 1 (length (window-list)))
        (delete-window)))))

(defun cb-eshell--new ()
  (window-configuration-to-register (cb-eshell--mk-register-name))
  (save-window-excursion
    (eshell t))
  (cb-eshell--show))

(defun cb-eshell--show ()
  (window-configuration-to-register (cb-eshell--mk-register-name))
  (pop-to-buffer (cb-eshell--buffer)))

(defun cb-eshell--buffer ()
  (let ((current-frame (cb-shell--current-frame)))
    (--first (with-current-buffer it
               (and (derived-mode-p 'eshell-mode)
                    (s-matches? "eshell" (buffer-name it))
                    (equal current-frame (window-frame (get-buffer-window it)))))
             (buffer-list))))

(defun cb-shell--current-frame ()
  (window-frame (get-buffer-window (current-buffer))))

(defun cb-eshell--mk-register-name ()
  (-let [(&alist 'window-id id) (frame-parameters (cb-shell--current-frame))]
    (intern (format "cb-eshell-%s" id))))


;;; Prompt

(defun eshell/host (&rest args)
  "Find the correct host name for this session."
  (or (file-remote-p default-directory 'host) system-name))

(make-variable-buffer-local 'eshell-last-command-status)

(defun cb-eshell--prompt ()
  (require 'magit)
  (let ((prompt
         (list
          :directory (f-full (eshell/pwd))
          :root-user? (= (user-uid) 0)
          :git (list
                :hash (magit-git-string "rev-parse" "HEAD")
                :tag  (magit-get-current-tag)
                :root
                (-when-let (root (locate-dominating-file (eshell/pwd) ".git"))
                  (f-full root))
                :branch (magit-get-current-branch)
                :staged? (magit-anything-staged-p)
                :unmerged? (magit-anything-unmerged-p)
                :untracked? (ignore-errors
                              (not (s-blank? (s-trim (shell-command-to-string "git ls-files --other --directory --exclude-standard")))))
                :unstaged? (magit-anything-staged-p)
                :modified? (magit-anything-modified-p))

          :last-command-success? (when (boundp 'eshell-last-command-status)
                                   (or (null eshell-last-command-status)
                                       (= eshell-last-command-status 0))))))
    (prog1 (propertize (cb-eshell--render-prompt prompt) 'read-only t 'rear-nonsticky t)
      (setq cb-eshell--last-prompt prompt))))

(defvar-local cb-eshell--last-prompt nil)

(defun cb-eshell--render-prompt (plist)
  (-let [(&plist :last-command-success? last-command-success?
                 :root-user? root-user?
                 ) plist]
    (concat
     (cond
      ((null cb-eshell--last-prompt)
       (concat (cb-eshell--render-header plist) "\n"))
      ((equal plist cb-eshell--last-prompt)
       "\n")
      (t
       (concat "\n\n" (cb-eshell--render-header plist) "\n")))

     (let ((colour (if last-command-success? solarized-hl-cyan solarized-hl-red)))
       (concat
        (propertize "λ" 'face `(:foreground ,colour))
        (propertize (if root-user? "#" ">") 'face `(:foreground ,colour))))

     " ")))

(defun cb-eshell--render-header (plist)
  (-let* (((&plist
            :directory dir
            :git
            (&plist
             :branch git-branch
             :hash git-hash
             :tag git-tag
             :root git-root
             :staged? git-staged?
             :unstaged? git-unstaged?
             :unmerged? git-unmerged?
             :untracked? git-untracked?
             :modified? git-modified?)
            ) plist)
          (sections (concat
                     ;; Display project info when at project root.
                     (when (equal git-root dir)
                       (-when-let (parts (-non-nil
                                          (list
                                           (when git-hash
                                             (concat (propertize "vc:" 'face font-lock-comment-face)
                                                     (propertize "git" 'face 'default)))
                                           (-when-let (lang (cb-eshell--project-lang git-root))
                                             (concat
                                              (propertize "lang:" 'face font-lock-comment-face)
                                              (propertize lang 'face 'default)))

                                           (-when-let (types (cb-eshell--project-types git-root))
                                             (concat
                                              (propertize "type:[" 'face font-lock-comment-face)
                                              (propertize (s-join " " types) 'face 'default)
                                              (propertize "]" 'face font-lock-comment-face)
                                              ))
                                           )))
                         (cb-eshell--prompt-section
                          (propertize "project " 'face font-lock-comment-face)
                          (s-join " " parts))))

                     ;; Git branch info and status.
                     (when git-root
                       (cb-eshell--prompt-section
                        (if git-branch
                            (concat
                             (propertize "branch:" 'face font-lock-comment-face)
                             (propertize git-branch 'face 'magit-branch-remote))
                          (propertize "DETACHED" 'face `(:foreground ,solarized-hl-orange)))

                        (when git-tag
                          (concat
                           (propertize " tag:" 'face font-lock-comment-face)
                           (propertize git-tag 'face 'magit-tag)))

                        (propertize " sha:" 'face font-lock-comment-face)
                        (propertize (substring git-hash 0 6) 'face 'default)

                        (-when-let (statuses
                                    (-non-nil (list
                                               (when git-staged? (propertize "staged" 'face `(:foreground ,solarized-hl-green)))
                                               (when git-unstaged? (propertize "unstaged" 'face `(:foreground ,solarized-hl-cyan)))
                                               (when git-unmerged? (propertize "unmerged" 'face `(:foreground ,solarized-hl-magenta)))
                                               (when git-modified? (propertize "modified" 'face `(:foreground ,solarized-hl-red)))
                                               (when git-untracked? (propertize "untracked" 'face 'default)))))
                          (concat
                           (propertize " state:[" 'face font-lock-comment-face)
                           (s-join " " (-non-nil statuses))
                           (propertize "]" 'face font-lock-comment-face)))))

                     ;; Git project subdirectory
                     (when git-hash
                       (let ((repo-subdirs (f-relative dir git-root)))
                         (cb-eshell--prompt-section
                          (propertize (s-chop-prefix "/" (concat "/" repo-subdirs)) 'face `(:foreground ,solarized-hl-blue))))))))
    (concat
     ;; Current directory or git project root.
     (propertize (f-abbrev (if git-hash (s-chop-suffix "/" git-root) dir)) 'face `(:foreground ,solarized-hl-blue))
     sections
     (unless (s-blank? sections) "\n"))))

(defun cb-eshell--prompt-section (&rest components)
  (concat "\n"
          (propertize " - " 'face font-lock-comment-face)
          (s-join "" components)))

(defun cb-eshell--project-lang (project-root)
  (let ((files (-map 'f-ext (f-files project-root))))
    (cond
     ((--any? (equal "cabal" it) files)
      "haskell")
     ((--any? (equal "hs" it) files)
      "haskell")
     ((--any? (equal "sbt" it) files)
      "scala")
     ((--any? (equal "scala" it) files)
      "scala")
     ((--any? (equal "el" it) files)
      "elisp"))))

(defun cb-eshell--project-types (project-root)
  (let ((files (f-files project-root)))
    (-non-nil
     (list

      (when (--any? (s-matches? (rx "/Cask" eos) it) files)
        "cask")

      (when (--any? (s-matches? (rx "/.travis.yml" eos) it) files)
        "travis")

      (when (--any? (s-matches? (rx "/.coveragerc" eos) it) files)
        "coveralls")

      (when (--any? (s-matches? (rx "/" (or "M" "m") "akefile" eos) it) files)
        "make")

      (when (--any? (s-matches? (rx ".cabal" eos) it) files)
        "cabal")

      ;; Scala projects

      (let ((build-sbt (f-join default-directory "build.sbt")))
        (-when-let ((_ scala-version)
                    (and (f-exists? build-sbt)
                         (s-match (rx bol (* space) "scalaVersion" (* space) ":=" (* space) "\"" (group (+ (any digit "."))))
                                  (f-read-text build-sbt 'utf-8))))
          scala-version))

      (when (--any? (s-matches? (rx ".sbt" eos) it) files)
        "sbt")

      (let ((sbt-plugins (f-join project-root "project/plugins.sbt")))
        (when (and (f-exists? sbt-plugins)
                   (s-contains? "com.typesafe.play" (f-read-text sbt-plugins 'utf-8)))
          "play"))

      (when (--any? (s-matches? (rx "/init.el" eos) it) files)
        "emacs.d")))))
