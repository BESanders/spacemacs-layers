(after 'scala-mode2
  (define-key scala-mode-map (kbd ".") nil)
  (evil-define-key 'normal scala-mode-map "J" 'scala/join-line)
  (define-key scala-mode-map (kbd "M-RET") 'scala/meta-ret)
  )
