;;; -*- lexical-binding: t -*-

(when (< emacs-major-version 31)
  (warn "This Emacs config was only tested with Emacs 31. It can thow errors! You have version %s!" emacs-major-version))

(add-to-list 'load-path (concat user-emacs-directory "modes"))

;; add MELPA to the list of ELPAs that Emacs will read.
(with-eval-after-load 'package
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

(package-initialize)

;; turn off the welcome screen, tool bars and scroll bars
(setopt inhibit-splash-screen 1)
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)

;; default mode for the *scratch* buffer
(setopt initial-major-mode 'fundamental-mode)
(setopt display-time-default-load-average nil)

;; Automatically reread from disk if the underlying file changes by
;; using the OS file change notification interface rather than
;; repeatedly polling to see if there are changes.
(setopt auto-revert-avoid-polling t)
(setopt auto-revert-interval 5)
(setopt auto-revert-check-vc-info t)
(global-auto-revert-mode)

;; Save history of minibuffer
(savehist-mode)

;; Save existing clipboard content to the kill ring---useful if you've
;; copied something from an external program and then kill some text
;; in Emacs shortly after. Also, deduplicate kill ring contents.
(setopt save-interprogram-paste-before-kill t)
(setopt kill-do-not-save-duplicates t)

;; Don't ping url-looking things when running find-file
(setopt ffap-machine-p-known 'reject)

;; Move through windows with Ctrl-<arrow keys>
(windmove-default-keybindings 'control)

;; Rebalance windows automatically when splitting
(setopt window-combination-resize t)

(setopt split-window-preferred-direction 'longest)

;; Fix archaic defaults
(setopt sentence-end-double-space nil)

;; Make all confirmation prompts use `y' or `n'
(setopt use-short-answers t)

;; Make right-click do something sensible and shift-drag behave better
(when (display-graphic-p)
  (mouse-shift-adjust-mode)
  (context-menu-mode))

;; Don't litter file system with *~ backup files
(setq-default make-backup-files nil)

;; tell Emacs to assume left-to-right text in all buffers.
(setq-default bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa 1)

(use-package which-key
  :config
  (which-key-mode))

(setopt enable-recursive-minibuffers t)                ; Use the minibuffer whilst in the minibuffer
(setopt completion-cycle-threshold t)                  ; TAB cycles candidates
(setopt completions-detailed t)                        ; Show annotations
(setopt tab-always-indent 'complete)                   ; When I hit TAB, try to complete, otherwise, indent
(setopt completion-styles '(basic initials substring)) ; Different styles to match input to candidates

(setopt minibuffer-visible-completions t)              ; Use ↑↓ to select candidates
(setopt completion-auto-help 'always)                  ; Open completion always; `lazy' another option
(setopt completions-max-height 20)                     ; This is an arbitrary value
(setopt completions-format 'one-column)                ; Makes it easier to scroll
(setopt completions-group t)

;; Eager completion setup: show *Completions* buffer immediately
(setopt completion-auto-select 'second-tab)            ; Much more eager
(setopt completion-eager-display t)                    ; Show the completions buffer immediately
(setopt completion-eager-update t)                     ; Update display as-you-type

(keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete)

;; isearch is Emacs's built-in searching system
(use-package isearch
  :ensure nil                           ; already installed
  :bind
  (:map isearch-mode-map
        ("C-." . isearch-forward-thing-at-point)) ; Search for thing under cursor
  :custom
  (lazy-count-prefix-format "(%s/%s) ")
  (isearch-lazy-count 1)                 ; show match count
  (isearch-allow-motion 1)
  (isearch-allow-scroll 1)               ; lets you scroll without breaking search
  (isearch-repeat-on-direction-change 1) ; C-r immediately goes to previous match
  (isearch-wrap-pause 'no-ding)          ; Automatically wrap search to top
  )

;; Mode line information
(setopt line-number-mode t)                        ; Show current line in modeline
(setopt column-number-mode t)                      ; Show column as well
(setopt mode-line-collapse-minor-modes nil)        ; nil default; set to `t' to hide minor modes
(setq-default display-line-numbers-width 3)
(global-display-line-numbers-mode)

;; Whitespace
(setq whitespace-style '(face tabs tab-mark spaces space-mark))
(global-whitespace-mode)

(setopt x-underline-at-descent-line nil)           ; Prettier underlines
(setopt switch-to-buffer-obey-display-actions t)   ; Make switching buffers more consistent

(setopt show-trailing-whitespace nil)      ; By default, don't underline trailing spaces
(setopt indicate-buffer-boundaries 'left)  ; Show buffer top and bottom in the margin

;; Enable horizontal scrolling
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)

;; Update the cursor shape inside a terminal; e.g. when in insert mode
;; when using Evil (Vim emulation) change the cursor to a bar.
(setopt xterm-update-cursor t)

(setopt tab-width 4)
(setopt indent-tabs-mode nil) ; Only use spaces to perform indentation

;; (blink-cursor-mode -1)

(pixel-scroll-precision-mode)
(setopt pixel-scroll-precision-interpolate-mice nil)

;; Makes it easier to repeat commands; `C-x o C-x o' becomes `C-x o o'
(repeat-mode)

;; Nice line wrapping when working with text
(add-hook 'text-mode-hook 'visual-line-mode)

;; Highlight the line with the cursor in all windows
(setopt global-hl-line-sticky-flag 'window)
(global-hl-line-mode)

;; Show matching delimiters
(setopt show-paren-delay 0)
(setopt show-paren-mode t)
(setopt show-paren-style 'expression)   ; default is 'parenthesis and just does delimiters
(setopt show-paren-context-when-offscreen 'overlay)

;; Show a tab bar near the buffer name
(setopt tab-bar-show t)

(add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-global 'append)

;; Eglot LSP Backend
(use-package eglot
  ;; no :ensure t here because it's built-in

  ;; Configure hooks to automatically turn-on eglot for selected modes
  :hook
  (((python-mode simpc-mode) . eglot-ensure))

  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref 1)              ; activate Eglot in referenced non-project files

  :config
  ;; Avoid changing line heights if your font is wonky. See
  ;; https://github.com/joaotavora/eglot/discussions/1492
  (setopt eglot-code-action-indicator "h")

  (fset #'jsonrpc--log-event #'ignore)  ; massive perf boost---don't log every event
  ;; Sometimes you need to tell Eglot where to find the language server
  (add-to-list 'eglot-server-programs
               '(simpc-mode . ("clangd")))

  ;; You can set various options for each language server. For
  ;; example, you can raise the number of completions surfaced by a
  ;; given langauge server to Emacs:
  ;; (setopt eglot-workspace-configuration )
)

;; Company LSP Frontend
(use-package company)
(global-company-mode)

;; Use common keybindings by default
(cua-mode)

;; TODO: Remap all keybindings better.

;;(setq global-map (make-keymap))
;;(define-key global-map [remap self-insert-command] 'self-insert-command)
;;(global-set-key (kbd "M-x") 'execute-extended-command) ; Execute commands
;;(global-set-key (kbd "C-q") 'save-buffers-kill-terminal) ; Quit Emacs safely
;;(global-set-key (kbd "C-s") 'save-buffer)               ; Save files

(set-frame-parameter nil 'alpha-background 85)
(add-to-list 'default-frame-alist '(alpha-background . 85))

;;(set-face-attribute 'default nil :height 100)
(set-frame-font "FiraCode Nerd Font Mono 18" nil t)

;;(use-package sorcery)

;;(load-theme 'sorcery 1)

(use-package ef-themes
  :ensure t
  :init
  ;; This makes the Modus commands listed below consider only the Ef
  ;; themes.  For an alternative that includes Modus and all
  ;; derivative themes (like Ef), enable the
  ;; `modus-themes-include-derivatives-mode' instead.  The manual of
  ;; the Ef themes has a section that explains all the possibilities:
  ;;
  ;; - Evaluate `(info "(ef-themes) Working with other Modus themes or taking over Modus")'
  ;; - Visit <https://protesilaos.com/emacs/ef-themes#h:6585235a-5219-4f78-9dd5-6a64d87d1b6e>
  (ef-themes-take-over-modus-themes-mode 1)
  ;;  :bind
  ;;  (("<f5>" . modus-themes-rotate)
  ;;   ("C-<f5>" . modus-themes-select)
  ;;   ("M-<f5>" . modus-themes-load-random))
  :config
  ;; All customisations here.
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t)

  ;; Finally, load your theme of choice (or a random one with
  ;; `modus-themes-load-random', `modus-themes-load-random-dark',
  ;; `modus-themes-load-random-light').
  ;;(modus-themes-load-theme 'ef-symbiosis)
  ;;(modus-themes-load-theme 'ef-bio)
  (modus-themes-load-theme 'ef-dark)
)

;; c-mode
(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "bsd")))

(use-package markdown-mode
  :hook ((markdown-mode . visual-line-mode)))

(use-package yaml-mode)
(use-package json-mode)

(require 'simpc-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("01a9797244146bbae39b18ef37e6f2ca5bebded90d9fe3a2f342a9e863aaa4fd"
     default))
 '(package-selected-packages
   '(gruber-darker-theme json-mode markdown-mode simpc-mode yaml-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
