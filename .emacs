;;;; -*- mode: emacs-lisp -*-

;;; 日本語環境設定
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)


;;; load-path
(setq load-path (cons "~/local/site-lisp" load-path))


;;; font-lockの設定
(global-font-lock-mode t)


;;; 各種キーバインド
(global-unset-key "\C-l")
(global-set-key "\C-l" 'goto-line)  ;; \C-lは元来'recenter
(global-unset-key "\C-t")  ;; 文字のトグルは押し間違えしかないのでoffに
(global-set-key "\C-m" 'newline-and-indent)  ;; Returnキーを押したあとindentもするように


;;; 表示まわり
(transient-mark-mode t)
(show-paren-mode t)
(line-number-mode t)
(column-number-mode t)


;;; インデントポリシー
(setq c-default-style "stroustrup")
(setq-default indent-tabs-mode nil)  ;; タブを使わずにスペースを使う
(setq-default tab-width 2)


;;; 保存時の設定
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;;; その他基本設定
(setq kill-whole-line t)  ;; 行頭でのC-kで行全体を削除
(setq backup-inhibited t)  ;; バックアップファイルを作らない
(setq delete-auto-save-files t)  ;; 終了時にオートセーブファイルを消す


;;; c-mode-common
(add-hook 'c-mode-common-hook
          '(lambda ()
             (progn
               (setq c-basic-offset 2)
               ;(local-set-key "\C-c\C-p" 'ps-print-buffer)
	     )))



;;; 高機能なバッファのスイッチ
(iswitchb-mode t)
; キーバインドの追加
(add-hook 'iswitchb-define-mode-map-hook
          'iswitchb-my-keys)
(defun iswitchb-my-keys ()
  "Add my keybindings for iswitchb."
  (define-key iswitchb-mode-map [right] 'iswitchb-next-match)
  (define-key iswitchb-mode-map [left] 'iswitchb-prev-match)
  (define-key iswitchb-mode-map "\C-f" 'iswitchb-next-match)
  (define-key iswitchb-mode-map " " 'iswitchb-next-match)
  (define-key iswitchb-mode-map "\C-b" 'iswitchb-prev-match)
  )

;;; バッファ名をユニークに
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)
(setq uniquify-ignore-buffers-re "*[^*]+*")



;;;flymake
(require 'flymake)

;;エラーメッセージをミニバッファで表示させる
(global-set-key "\C-n" 'flymake-goto-next-error)
(global-set-key "\M-n" 'flymake-goto-prev-error)

;; gotoした際にエラーメッセージをminibufferに表示する
(defun display-error-message ()
  (message (get-char-property (point) 'help-echo)))
(defadvice flymake-goto-prev-error (after flymake-goto-prev-error-display-message)
  (display-error-message))
(defadvice flymake-goto-next-error (after flymake-goto-next-error-display-message)
  (display-error-message))
(ad-activate 'flymake-goto-prev-error 'flymake-goto-prev-error-display-message)
(ad-activate 'flymake-goto-next-error 'flymake-goto-next-error-display-message)

;;c++のflymakeでmakefileを不要にする
(defun flymake-cc-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list "g++" (list "-Wall" "-Wextra" "-fsyntax-only" local-file))))

(push '("\\.cc$" flymake-cc-init) flymake-allowed-file-name-masks)
(push '("\\.cpp$" flymake-cc-init) flymake-allowed-file-name-masks)
(push '("\\.h$" flymake-cc-init) flymake-allowed-file-name-masks)
(push '("\\.hpp$" flymake-cc-init) flymake-allowed-file-name-masks)

(add-hook 'c++-mode-hook '(lambda ()
  (flymake-mode t)
))
