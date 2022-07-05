(setq default-directory "~/"
      command-line-default-directory "~"
      exec-path (mapcar
                 'expand-file-name
                 (parse-colon-path (concat "~/bin:~/.local/bin:~/.anyenv/envs/tfenv/bin:/usr/local/bin:/usr/local/sbin:" (getenv "PATH"))))
      scratch-buffer-file (locate-user-emacs-file "scratch"))

(add-hook
 'kill-buffer-hook
 `(lambda ()
    (when (equal
           (current-buffer)
           (get-buffer "*scratch*"))
      (rename-buffer "*scratch*<kill>" t)
      (clone-buffer "*scratch*")) t))

(add-hook
 'after-init-hook
 `(lambda ()
    (when (file-exists-p scratch-buffer-file)
      (with-current-buffer (get-buffer-create "*scratch*")
        (erase-buffer)
        (insert-file-contents scratch-buffer-file))) t))

(add-hook
 'kill-emacs-hook
 `(lambda ()
    (with-current-buffer (get-buffer-create "*scratch*")
      (write-region (point-min) (point-max) scratch-buffer-file nil t)) t))

(add-hook
 'kill-emacs-hook
 `(lambda ()
    (let ((src-file (locate-user-emacs-file "init.el"))
          (elc-file (locate-user-emacs-file "init.elc")))
      (when (file-newer-than-file-p src-file elc-file)
        (byte-compile-file src-file))) t))

(add-hook
 'kill-emacs-hook
 `(lambda ()
    (when (file-exists-p custom-file)
      (delete-file custom-file)) t))

(add-hook
 'window-configuration-change-hook
 `(lambda ()
    (let ((display-table (or buffer-display-table standard-display-table)))
      (when display-table
        ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Display-Tables.html
        (set-display-table-slot display-table 1 ? )
        (set-display-table-slot display-table 5 ?│)
        (set-window-display-table (selected-window) display-table))) t))

(add-hook
 'after-save-hook
 'executable-make-buffer-file-executable-if-script-p)

(custom-set-variables
 '(custom-file (locate-user-emacs-file (format "emacs-%d.el" (emacs-pid))))
 '(ffap-bindings t)
 '(find-file-visit-truename t)
 '(global-auto-revert-mode t)
 '(indent-tabs-mode nil)
 '(inhibit-splash-screen t)
 '(inhibit-startup-screen t)
 '(initial-scratch-message nil)
 '(make-backup-files nil)
 '(package-archives '(("melpa" . "https://melpa.org/packages/")
                      ("elpa" . "https://elpa.gnu.org/packages/")))
 '(package-enable-at-startup t)
 '(pop-up-windows nil)
 '(require-final-newline 'visit-save)
 '(scroll-step 1)
 '(set-mark-command-repeat-pop t)
 '(split-width-threshold 0)
 '(system-time-locale "C")
 '(show-paren-mode t)
 '(vc-follow-symlinks nil)
 '(view-read-only t)
 '(viper-mode nil))

(load-theme 'anticolor t)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(eval-and-compile
  (package-initialize)

  (run-with-idle-timer
   (* 60 60 6) t (lambda () (package-refresh-contents)))

  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf
    :config
    (leaf leaf-keywords
      :ensure t
      :init
      ;; (leaf hydra :ensure t)
      ;; (leaf el-get :ensure t)
      ;; (leaf blackout :ensure t)
      :config
      (leaf-keywords-init))))

(leaf coffee-mode
  :ensure t
  :custom
  (cofee-tab-width . 2))

(leaf company
  :ensure t
  :bind (("C-c i" . company-complete))
  :hook (after-init-hook . global-company-mode)
  :custom
  (company-idle-delay . nil)
  (company-selection-wrap-around . t)
  :config
  (leaf company-statistics
    :ensure t
    :hook (after-init-hook . company-statistics-mode))
  (leaf company-c-headers :ensure t :config (add-to-list 'company-backends 'company-c-headers))
  (leaf company-shell :ensure t :config (add-to-list 'company-backends 'company-shell))
  (leaf company-terraform :ensure t :config (add-to-list 'company-backends 'company-terraform))
  ;;(leaf company-web :ensure t :config (add-to-list 'company-backends 'company-web))
  )

(leaf dockerfile-mode :ensure t)

(leaf editorconfig :ensure t)

(leaf eshell
  :bind ("C-c #" . eshell)
  :config
  (defun eshell/hello ()
    (message "hello world")))

(leaf flycheck :ensure t)

(leaf ido
  :hook ((after-init-hook . ido-mode)
         (after-init-hook . ido-everywhere))
  :custom
  (ido-enable-flex-matching . t)
  (ido-use-faces . t)
  :init
  (leaf imenu-anywhere
    :ensure t
    :bind ("M-." . ido-imenu-anywhere))
  (leaf smex
    :ensure t
    :bind (("M-x" . smex)
           ("M-X" . mex-major-mode-commands)))
  (leaf ido-vertical-mode
    :ensure t
    :hook (after-init-hook . ido-vertical-mode)
    :custom
    (ido-vertical-define-keys . 'C-n-and-C-p-only)))

(leaf k8s-mode :ensure t)

(leaf macrostep
  :ensure t
  :bind ("C-c e" . macrostep-expand))

(leaf open-junk-file
  :ensure t
  :hook (kill-emacs-hook . open-junk-file/delete)
  :bind ("C-c j" . open-junk-file)
  :init
  (setq open-junk-file-directory (locate-user-emacs-file "junk/")
        open-junk-file-format (concat open-junk-file-directory "%s."))
  (defun open-junk-file/delete ()
    (interactive)
    (when (file-directory-p open-junk-file-directory)
      (delete-directory open-junk-file-directory))))

(leaf popwin
  :ensure t
  :hook (after-init-hook . popwin-mode)
  :config
  (mapcar
   #'(lambda (x) (push x popwin:special-display-config))
   '(("*Buffer List*")
     ("*eshell*" :height 30 :dedicated t :stick t)
     ("*Warnings*"))))

(leaf markdown-mode :ensure t)

(leaf markdown-preview-mode :ensure t)

(leaf rainbow-mode :ensure t)

(leaf terraform-mode
  :ensure t
  :hook (terraform-mode-hook . terraform-format-on-save-mode)
  :config
  (leaf terraform-doc :ensure t))

(leaf whitespace
  :hook ((after-init-hook . global-whitespace-mode)
         (before-save-hook . whitespace-cleanup))
  :custom
  (whitespace-space-regexp . "\\(\u3000+\\)")
  (whitespace-style . '(face trailing spaces empty space-mark tab-mark))
  (whitespace-display-mappings . '((space-mark ?\u3000 [?\u25a1])
                                   (tab-mark ?\t [?\u00bb ?\t] [?\\ ?\t])))
  (whitespace-action . '(auto-cleanup)))

(leaf xclip
  :if (or (executable-find "xclip")
          (executable-find "xsel")
          (executable-find "pbcopy"))
  :ensure t
  :hook (after-init-hook . xclip-mode))

(leaf yaml-mode :ensure t)
