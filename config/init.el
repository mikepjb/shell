;; -*- lexical-binding: t; -*-
(setq gc-cons-threshold (* 64 1024 1024))

;; i. variables ----------------------------------------------------------------

(defvar project-vc-extra-root-markers
  '("Makefile" "gradlew" "pom.xml" "go.mod" "package.json" "deps.edn"))

(defconst +repl-config
  '(("clojure" inferior-lisp "clojure -A:dev")
    ("sicp"    racket)
    ("java"    comint-run "jshell")
    ("python"  run-python)
    ("sqlite"  sql-sqlite)
    ("node"    comint-run "node")
    ("ruby"    comint-run "irb")))

;; ii. functions & macros ------------------------------------------------------

(defmacro +with-context (&rest body)
  "Execute BODY with `default-directory' bound to the current project root."
  `(let ((default-directory (if-let ((proj (project-current)))
                                (project-root proj)
                              default-directory)))
     ,@body))

(defun +repl (&optional arg)
  (interactive "P")
  (let* ((choice (if arg 
                     (completing-read "REPL: " (mapcar #'car +repl-config) nil t)
                   "clojure"))
         (spec (cdr (assoc choice +repl-config))))
    (when spec
      (other-window-prefix)
      (+with-context (apply (car spec) (cdr spec))))))

(defmacro il (&rest body) `(lambda () (interactive) ,@body))
(defmacro ff (&rest path) `(il (find-file (concat ,@path))))

(defun +other-window-or-split ()
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

(defun +ctags ()
  (interactive)
  (+with-context
   (make-process
    :name "ctags" :buffer nil
    :command '("ctags" "-eR" "-f" ".tags"
               "--exclude=node_modules" "--exclude=dist" ".")
    :sentinel (lambda (_ e) (message "ctags: %s" (string-trim e))))))

(defun +ctags-link ()
  (when-let ((dir (locate-dominating-file default-directory ".tags")))
    (let ((tags-file (expand-file-name ".tags" dir)))
      (when (and (file-regular-p tags-file)
                 (not (member tags-file tags-table-list)))
        (visit-tags-table tags-file t)))))

(defun +lisp-load-current-file ()
  (interactive)
  (lisp-load-file (buffer-file-name)))

;; iii. Packages ---------------------------------------------------------------

(add-to-list 'load-path (concat user-emacs-directory "lisp"))
(load-theme 'flow t)

(dolist
    (m
     '((paredit-mode "paredit" nil)
       (clojure-mode "clojure-mode" ("\\.clj\\'" . clojure-mode))
       (clojurescript-mode "clojure-mode" ("\\.cljs\\'" . clojurescript-mode))
       (clojurec-mode "clojure-mode" ("\\.cljc\\'" . clojurec-mode))
       (edn-mode "clojure-mode" ("\\.edn\\'" . edn-mode))
       (go-mode "go-mode" ("\\.go\\'" . go-mode))))
  (let ((mode (car m))
        (lib (cadr m))
        (cell (nth 2 m)))
    (autoload mode lib "" t)
    (when cell
      (add-to-list 'auto-mode-alist cell))))

;; iv. Configuration and hooks -------------------------------------------------

(dolist (k '(mac-command-modifier x-super-keysym))
  (when (boundp k) (set k 'meta)))

(set-face-attribute 'default nil  :font "Rec Mono Linear" :height 160)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(fringe-mode 0)
(electric-pair-mode 1)
(show-paren-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(global-auto-revert-mode 1)
(fido-mode 1)

(add-hook
 'prog-mode-hook
 (lambda ()
    (display-line-numbers-mode 1)
    (hl-line-mode 1)
    (display-fill-column-indicator-mode 1)))

(add-hook
 'term-mode-hook
 (lambda ()
   (compilation-shell-minor-mode)
   (define-key term-raw-map (kbd "M-o") '+other-window-or-split)
   (define-key term-raw-map (kbd "M-x") 'execute-extended-command)
   (define-key term-raw-map (kbd "M-:") 'eval-expression)))

(add-hook
 'clojure-mode-hook
 (lambda ()
   (setq-local inferior-lisp-load-command "(load-file \"%s\")\n")
   (define-key clojure-mode-map (kbd "C-x C-e") 'lisp-eval-last-sexp)
   (define-key clojure-mode-map (kbd "C-M-x") 'lisp-eval-defun)
   (define-key clojure-mode-map (kbd "C-c C-k") '+lisp-load-current-file)))



(dolist (hook '(emacs-lisp-mode-hook
                lisp-mode-hook
                lisp-interaction-mode-hook ; For the *scratch* buffer
                scheme-mode-hook           ; Often used for Racket/SICP
                clojure-mode-hook))
  (add-hook hook (lambda () (paredit-mode 1))))

(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(add-hook 'find-file-hook #'+ctags-link)

(add-hook 'org-mode-hook #'org-indent-mode)

(with-eval-after-load 'icomplete
  (define-key icomplete-minibuffer-map (kbd "C-w") #'backward-kill-word))

(with-eval-after-load 'paredit
  (define-key paredit-mode-map (kbd "M-s") nil)
  (define-key paredit-mode-map (kbd "M-;") nil)
  (define-key paredit-mode-map (kbd "C-c s") #'paredit-splice-sexp)
  (define-key paredit-mode-map (kbd "M-k") #'paredit-forward-barf-sexp)
  (define-key paredit-mode-map (kbd "M-l") #'paredit-forward-slurp-sexp))

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
 create-lockfiles nil
 make-backup-files nil
 auto-save-default nil
 isearch-wrap-pause 'no
 compilation-always-kill t
 compilation-scroll-output t
 custom-file (concat user-emacs-directory "local.el")
 org-modules nil
 org-ellipsis " ▼"
 ;; org-startup-folded 'show3levels
 org-startup-with-inline-images t
 org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "CURRENT(c)" "|" "DONE(d!)"))
 org-log-into-drawer t
 org-log-done 'time
 org-agenda-span 14
 org-agenda-start-on-weekday nil
 org-agenda-restore-windows-after-quit t
 js-indent-level 2)

(setq-default
 display-fill-column-indicator-column 80
 truncate-lines t
 indent-tabs-mode nil
 tab-width 2
 standard-indent 2
 whitespace-style '(face trailing tabs empty indentation::space)
 cursor-in-non-selected-windows nil)

(c-add-style ;; custom java intendation style
 "+java"
 '("stroustrup" (c-offsets-alist . ((arglist-cont-nonempty . 0)
                                    (statement-block-intro . +)))))

(with-eval-after-load 'grep
  (dolist (dir '("node_modules" "dist" "build" "target" ".tags" ".idea"))
    (add-to-list 'grep-find-ignored-directories dir)))

;; (keymap-global-set "M-s" #'save-buffer)
;; (keymap-global-set "M-o" #'other-window-or-split)
(dolist (b `(
	           ("M-s" save-buffer)
	           ("M-o" +other-window-or-split)
	           ("M-O" delete-other-windows)
	           ("M-H" ,help-map)
	           ("M-RET" toggle-frame-fullscreen)
             ("M--" ,(il (set-frame-size nil 160 55)))
             ("C-;" hippie-expand)
             ("M-;" completion-at-point)
             ("M-/" comment-line)
	           ("M-p" backward-paragraph)
	           ("M-n" forward-paragraph)
             ("C-h" delete-backward-char)
             ("C-j" newline) ;; autoindents
	           ("M-j" ,(il (join-line -1)))
	           ("C-c i" ,(ff user-emacs-directory "init.el"))
             ("C-c n" ,(ff (getenv "HOME") "/.notes/index.org"))
             ("M-i" ,(il (+with-context (call-interactively 'rgrep))))
             ("M-I" ,(il (+with-context (call-interactively 'occur))))
             ("C-c u" imenu) ;; bad binding but also a reminder for i(ndex)menu
	           ("M-R" +repl)
	           ("C-w" +kill-region-or-backward-word)
	           ("C-z" ,(il (ansi-term "/usr/bin/env bash")))
             ("C-c p" project-find-file)
             ("C-c o" find-file) ;; more ergonomic than C-x C-f
	           ))
  (global-set-key (kbd (car b)) (cadr b)))

(let ((path-str (shell-command-to-string
                 "/bin/bash -c 'source $HOME/.bashrc && printf $PATH'")))
  (setenv "PATH" path-str)
  (setq exec-path (split-string path-str ":")))

(require 'server)
(unless (server-running-p)
  (server-start))
