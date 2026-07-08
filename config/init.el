(setq gc-cons-threshold (* 64 1024 1024))

;; TODO are we able to set this first and have the function/macro
;; definitions later on? and then call (+setup) at the end of the
;; file?
;; (defun +setup ()
;;   "Configures Emacs so it is ready for action!")

(defmacro +setm (&rest modes)
  "Sets modes according to the MODES interpreted as pairs using seq-partition."
  (let (body)
    (dolist (m (seq-partition modes 2))
      (push `(,(car m) ,(cadr m)) body))
    `(progn ,@(nreverse body))))


;; ;; repls
;; (defun +repl (&optional arg)
;;   (interactive "P")
;;   (let* ((repls '(("clojure" inferior-lisp "clojure -A:dev")
;;                   ("python" run-python)
;;                   ("sqlite" sql-sqlite)
;;                   ("node" comint-run "node")
;;                   ("ruby" comint-run "irb")))
;;          (spec (cdr (assoc (if arg (completing-read "REPL: " repls nil t)
;;                              "clojure")
;;                            repls))))
;;     (other-window-prefix)
;;     (apply (car spec) (cdr spec))))

(dolist (k '(mac-command-modifier x-super-keysym))
  (when (boundp k) (set k 'meta)))

(set-face-attribute 'default nil  :font "Rec Mono Linear" :height 160)

(load-theme 'modus-vivendi t) ;; or tango-dark / wombat

(+setm
 menu-bar-mode -1
 tool-bar-mode -1
 scroll-bar-mode -1
 blink-cursor-mode -1
 electric-pair-mode 1
 show-paren-mode 1
 savehist-mode 1
 save-place-mode 1
 global-auto-revert-mode 1
 fido-mode 1)

(setq
 inhibit-startup-screen t
 ring-bell-function 'ignore
 )

(+setr
 "clojure" '(inferior-lisp "clojure -A:dev")
 "python" run-python
 "sqlite" sql-sqlite
 "node" '(comint-run "node")
 "ruby" '(comint-run "irb"))

(dolist (b `(
	     ("M-s" save-buffer)
	     ("M-o" other-window)
	     ("M-H" ,help-map)
	     ("M-RET" toggle-frame-fullscreen)
	     ("M-p" backward-paragraph)
	     ("M-n" forward-paragraph)
             ("C-h" delete-backward-char)
             ("C-j" newline) ;; autoindents
	     ))
  (global-set-key (kbd (car b)) (cadr b)))

;; C-w (maybe another way?)
;; paredit
;; REPLs! (incl. sql! clojure/racket (for SICP)/python/jshell)
