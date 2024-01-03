;; Recolor line number in selected window to help visually identify that window.
;;
;; There are some packages out there, like auto-dim-buffer-mode, but they all
;; either (1) operate on buffers which means splitting a buffer highlights two
;; windows or (2) affect the entire window which is too distracting.  (I will
;; contact the authors and see if they want to add this functionality.)
;;
;; For now, I'm using a simple technique of using filtered face remapping.  I've
;; made up a window parameter named `awm--dim` and when it is set to true, the
;; face remapping will automatically override the normal line numbers with the
;; dimmed one defined below.
;;
;; The selected window uses the built-in line number faces.  Non-selected
;; windows will use the face below.


(defface dim-line-number
 '((t :foreground "#505050"))
    "Face for line numbers in inactive windows")


(defun dln--update ()
  "Updates each window line number color"
  (interactive)
  (walk-windows
   (lambda (window)
     (let ((is-dim (not (eq (selected-window) window)))
           (is-marked (window-parameter window 'awm--dim)))
       ;;  (message "awm-update %s is=%s marked=%s" window is-dim is-marked)
       (when (not (eq is-dim is-marked))
         ;;  (message "updating window %s" window)
         (set-window-parameter window 'awm--dim is-dim)
         (force-window-update window)
       ))
     nil t)))


(defun dln--turn-on ()
  ;; Normally you are supposed to use face-remap-add-relative, but that makes it
  ;; local.  I'd prefer to set this just once globally.
  (add-to-list 'face-remapping-alist
               '(line-number (:filtered (:window awm--dim t)
                                        dim-line-number)
                             line-number))
  (add-to-list 'face-remapping-alist
               '(line-number-current-line (:filtered (:window awm--dim t)
                                                     dim-line-number)
                                          line-number-current-line))
  (add-hook 'window-state-change-hook 'dln--update))

(defun dln--turn-off ()
  (assq-delete-all 'line-number face-remapping-alist)
  (assq-delete-all 'line-number-current-line face-remapping-alist)
  (remove-hook 'window-state-change-hook 'dln--update))


;;;###autoload
(define-minor-mode dim-line-numbers-mode
  "Dims line numbers of inactive windows."
  :global t
  (if dim-line-numbers-mode
      (dln--turn-on)
    (dln--turn-off))
  (dln--update))


(provide 'dim-line-numbers-mode)
