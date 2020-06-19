;;; initfile --- Life-Scripting
;;; Commentary:
;; Emacs 23.3 and newer tested

;;;; Send region and line to ansi-term
;; https://emacs.stackexchange.com/questions/28122/how-to-execute-shell-command-from-editor-window/28126#28126
(defun send-region-to-ansi ()
  "If region active, send it to ansi-term buffer."
  (interactive)
  (if (region-active-p) 
      (send-region "*ansi-term*" (region-beginning) (region-end))))

;; Meine Erweiterungum Lines zu senden
(defun my-select-current-line ()
  "Selects the current line, including the NEXT-LINE char at the end"
  (interactive)
  (move-beginning-of-line nil)
  (set-mark-command nil)
  (move-end-of-line 2)
  (move-beginning-of-line nil)
  (setq deactivate-mark nil))

(defun send-line-to-ansi ()
  "If region active, send it to ansi-term buffer."
  (interactive)
  (my-select-current-line)
  (if (region-active-p)
      (send-region "*ansi-term*" (region-beginning) (region-end)))
   (deactivate-mark 1))

;; das funktioniert sehr gut. Binden auf F8
(global-set-key [f5] 'send-line-to-ansi)
(global-set-key [f6] 'send-region-to-ansi)
(global-set-key [f7] 'other-window)
(global-set-key (kbd "C-n") 'other-window)

;; In ansi-term toggle between char run/line run mode.
;;http://joelmccracken.github.io/entries/switching-between-term-mode-and-line-mode-in-emacs-term/
(defun jnm/term-toggle-mode ()
  "Toggles term between line mode and char mode"
  (interactive)
  (if (term-in-line-mode)
      (term-char-mode)
    (term-line-mode)))
(global-set-key [f8] 'jnm/term-toggle-mode)
