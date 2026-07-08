(setq gc-cons-threshold (* 64 1024 1024))

;; TODO eshell configured for git di to not say this is not a terminal lol
;; TODO eshell configure to work with C-u to kill line and C-l to clear

(add-to-list 'load-path (concat user-emacs-directory "lisp"))

(defmacro +setm (&rest modes)
  "Sets modes according to the MODES interpreted as pairs using seq-partition."
  (let (body)
    (dolist (m (seq-partition modes 2))
      (push `(,(car m) ,(cadr m)) body))
    `(progn ,@(nreverse body))))

(defun +repl (&optional arg)
  (interactive "P")
  (let* ((choice (if arg (completing-read "REPL: " +repl-config nil t)
	    "clojure"))
	 (spec (cdr (assoc +repl-config))))
    (other-window-prefix)
    (apply (car spec) (cdr spec))))

(defmacro il (&rest body) `(lambda () (interactive) ,@body))
(defmacro ff (&rest path) `(il (find-file (concat ,@path))))

(defun other-window-or-split ()
  "If one window, split, otherwise invoke 'other-window'"
  (interactive)
  (when (= (length (window-list)) 1)
      (split-window-right))
  (other-window 1))

(defun +kill-region-or-backward-word ()
  (interactive)
  (cond ((region-active-p) (call-interactively #'kill-region))
        ((bound-and-true-p paredit-mode) (paredit-backward-kill-word))
        (t (backward-kill-word 1))))

;; TODO really want to get rid of this, there must be a simpler way to
;; affect this C-w behaviour inside the minibuffer.
;; Support C-w to go up/back a directory in the minibuffer/ido mode
(with-eval-after-load 'icomplete
  (define-key icomplete-minibuffer-map (kbd "C-w")
    (lambda () (interactive)
      (if (string-match-p "/" (minibuffer-contents))
          (icomplete-fido-backward-updir) (backward-kill-word 1))))
  (define-key icomplete-minibuffer-map (kbd "C-e") #'icomplete-ret))

(dolist (k '(mac-command-modifier x-super-keysym))
  (when (boundp k) (set k 'meta)))

(set-face-attribute 'default nil  :font "Rec Mono Linear" :height 160)

(load-theme 'flow t)

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

(add-hook
 'prog-mode-hook
 (lambda ()
   (+setm
    display-line-numbers-mode 1
    hl-line-mode 1
    display-fill-column-indicator-mode 1)))

(dolist (hook '(emacs-lisp-mode-hook
                lisp-mode-hook
                lisp-interaction-mode-hook ; For the *scratch* buffer
                scheme-mode-hook           ; Often used for Racket/SICP
		;; eval-expression-minibuffer-setup
                clojure-mode-hook))
  (add-hook hook (lambda () (+setm paredit-mode 1))))

(with-eval-after-load 'paredit
  (define-key paredit-mode-map (kbd "M-s") nil)
  (define-key paredit-mode-map (kbd "C-c s") #'paredit-splice-sexp))

(setq
 inhibit-startup-screen t
 ring-bell-function 'ignore
 eshell-banner-message ""
 use-dialog-box nil
 use-file-dialog nil
 use-short-answers t
 split-width-threshold 160
 split-height-threshold nil
 frame-resize-pixelwise t
 c-default-style '((java-mode . "+java") (other . "gnu"))
 c-basic-offset 4
 vc-follow-symlinks t
 compilation-always-kill t
 compilation-scroll-output t
 custom-file (concat user-emacs-directory "local.el")
 package-archives '(("melpa" . "https://melpa.org/packages/")
                    ("gnu" . "https://elpa.gnu.org/packages/")))

(c-add-style ;; custom java intendation style
 "+java"
 '("stroustrup" (c-offsets-alist . ((arglist-cont-nonempty . 0)
                                    (statement-block-intro . +)))))

(defconst +repl-config
  '("clojure" '(inferior-lisp "clojure -A:dev")
    "sicp" "racket"
    "python" run-python
    "sqlite" sql-sqlite
    "node" '(comint-run "node")
    "ruby" '(comint-run "irb")))

(dolist (b `(
	     ("M-s" save-buffer)
	     ("M-o" other-window-or-split)
	     ("M-O" delete-other-windows)
	     ("M-H" ,help-map)
	     ("M-RET" toggle-frame-fullscreen)
	     ("M-p" backward-paragraph)
	     ("M-n" forward-paragraph)
             ("C-h" delete-backward-char)
             ("C-j" newline) ;; autoindents
	     ("M-j" ,(il (join-line -1)))
	     ("C-c i" ,(ff user-emacs-directory "init.el"))
	     ("M-R" +repl)
	     ("C-w" +kill-region-or-backward-word)
	     ))
  (global-set-key (kbd (car b)) (cadr b)))

;; TODO in-progress sketching out improving the autoload/add-to-list invocations below.
;; (+autoload "clojure-mode '(())")

(autoload 'paredit-mode "paredit" "" t)
(autoload 'clojure-mode "clojure-mode" "" t)
(autoload 'clojurescript-mode "clojure-mode" "" t)
(autoload 'clojurec-mode "clojure-mode" "" t)
(autoload 'edn-mode "clojure-mode" "" t)

(add-to-list 'auto-mode-alist '("\\.clj\\'" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.cljs\\'" . clojurescript-mode))
(add-to-list 'auto-mode-alist '("\\.cljc\\'" . clojurec-mode))
(add-to-list 'auto-mode-alist '("\\.edn\\'" . edn-mode))

;; C-w (maybe another way?)
