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
(setopt auto-revert-avoid-polling 1)
(setopt auto-revert-interval 5)
(setopt auto-revert-check-vc-info 1)
(global-auto-revert-mode)

;; Save history of minibuffer
(savehist-mode)

;; Save existing clipboard content to the kill ring---useful if you've
;; copied something from an external program and then kill some text
;; in Emacs shortly after. Also, deduplicate kill ring contents.
(setopt save-interprogram-paste-before-kill 1)
(setopt kill-do-not-save-duplicates 1)

;; Don't ping url-looking things when running find-file
(setopt ffap-machine-p-known 'reject)

;; Move through windows with Ctrl-<arrow keys>
(windmove-default-keybindings 'control)

;; Rebalance windows automatically when splitting
(setopt window-combination-resize 1)

(setopt split-window-preferred-direction 'longest)

;; Fix archaic defaults
(setopt sentence-end-double-space nil)

;; Make all confirmation prompts use `y' or `n'
(setopt use-short-answers 1)

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

(setopt enable-recursive-minibuffers 1)                ; Use the minibuffer whilst in the minibuffer
(setopt completion-cycle-threshold 1)                  ; TAB cycles candidates
(setopt completions-detailed 1)                        ; Show annotations
(setopt tab-always-indent 'complete)                   ; When I hit TAB, try to complete, otherwise, indent
(setopt completion-styles '(basic initials substring)) ; Different styles to match input to candidates

(setopt minibuffer-visible-completions 1)              ; Use ↑↓ to select candidates
(setopt completion-auto-help 'always)                  ; Open completion always; `lazy' another option
(setopt completions-max-height 20)                     ; This is an arbitrary value
(setopt completions-format 'one-column)                ; Makes it easier to scroll
(setopt completions-group 1)

;; Eager completion setup: show *Completions* buffer immediately
(setopt completion-auto-select 'second-tab)            ; Much more eager
(setopt completion-eager-display 1)                    ; Show the completions buffer immediately
(setopt completion-eager-update 1)                     ; Update display as-you-type

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
(setopt line-number-mode 1)                        ; Show current line in modeline
(setopt column-number-mode 1)                      ; Show column as well
(setopt mode-line-collapse-minor-modes nil)        ; nil default; set to `t' to hide minor modes
(setq-default display-line-numbers-width 3)
(global-display-line-numbers-mode)

;; Whitespace
(setq whitespace-style '(face tabs tab-mark spaces space-mark))
(global-whitespace-mode)

(setopt x-underline-at-descent-line nil)           ; Prettier underlines
(setopt switch-to-buffer-obey-display-actions 1)   ; Make switching buffers more consistent

(setopt show-trailing-whitespace nil)      ; By default, don't underline trailing spaces
(setopt indicate-buffer-boundaries 'left)  ; Show buffer top and bottom in the margin

;; Enable horizontal scrolling
(setopt mouse-wheel-tilt-scroll 1)
(setopt mouse-wheel-flip-direction 1)

;; Update the cursor shape inside a terminal; e.g. when in insert mode
;; when using Evil (Vim emulation) change the cursor to a bar.
(setopt xterm-update-cursor 1)

(setopt tab-width 4)
(setopt indent-tabs-mode nil) ; Only use spaces to perform indentation

;; (blink-cursor-mode -1)

(pixel-scroll-precision-mode)
(setopt pixel-scroll-precision-interpolate-mice nil)

;; Use common keystrokes by default
(cua-mode)

;; Makes it easier to repeat commands; `C-x o C-x o' becomes `C-x o o'
(repeat-mode)

;; Nice line wrapping when working with text
(add-hook 'text-mode-hook 'visual-line-mode)

;; Highlight the line with the cursor in all windows
(setopt global-hl-line-sticky-flag 'window)
(global-hl-line-mode)

;; Show matching delimiters
(setopt show-paren-delay 0)
(setopt show-paren-mode 1)
(setopt show-paren-style 'expression)   ; default is 'parenthesis and just does delimiters
(setopt show-paren-context-when-offscreen 'overlay)

;; Show a tab bar near the buffer name
(setopt tab-bar-show 1)

(add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-global 'append)

(use-package gruber-darker-theme)

(load-theme 'gruber-darker 1)

(use-package markdown-mode
  :hook ((markdown-mode . visual-line-mode)))

(use-package yaml-mode)
(use-package json-mode)

(require 'simpc-mode)

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

;; c-mode
(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "bsd")))

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
