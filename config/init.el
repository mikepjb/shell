(setq gc-cons-threshold (* 64 1024 1024))

(dolist (k '(mac-command-modifier x-super-keysym))
  (when (boundp k) (set k 'meta)))

(set-face-attribute 'default nil  :font "Rec Mono Linear" :height 160)

(load-theme 'modus-vivendi t) ;; or tango-dark / wombat

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(electric-pair-mode 1)
(show-paren-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(global-auto-revert-mode 1)
(fido-mode 1)

(defun +setm (&rest modes)
  "Sets modes according to the MODES interpreted as tuples."
  (dolist (m (seq-partition modes 2))
    ;; (message (car m) (cdr m))
    (funcall (car m) (cdr m))))

(+setm
 menu-bar-mode 1
 tool-bar-mode -1)

(setq
 inhibit-startup-screen t
 ring-bell-function 'ignore
 )

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

;; line numbers (code only)
;; C-w (maybe another way?)
;; paredit
;; REPLs! (incl. sql! clojure/racket (for SICP)/python/jshell)
