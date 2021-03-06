;;;;;;;;;;;;;;;;;;
;;planner-org-freundshaft


;;these are the keybindings im used to cenverted to org:

;;(global-set-key (kbd "<f9> p") 'org-capture)
;;(global-set-key (kbd "<f9> a") 'org-agenda)


(defun pof-planner-task-to-org-task ()
  "reformat a planner task to an org task"
  ;;  BUG  if theres a - list before the task. wtf?
  (interactive)
  (save-excursion
    (move-beginning-of-line nil)
    (let
        ((task (planner-current-task-info)))
      
      (kill-line)
      ;;if the previous heading was a todo then promote the heading
      ;;because otherwise the conversion of consequtive planner tasks gets to be trees
      ;;and i want them to live at their non-task parent
      (org-insert-heading t)
      (org-demote)
      ;;      (org-insert-todo-subheading t)
      (if (save-excursion
            (org-up-heading-safe)
            (nth 2 (org-heading-components)))
          (org-promote))
      
      (move-end-of-line nil)      
      
      (insert (planner-task-description task))
      (cond
       ((equal "X" (planner-task-status task))
        (org-todo 'done))
       ((equal "C" (planner-task-status task))
        (org-todo "CANCELLED"))
       )
      (if (planner-task-date task)
          ;;  (flet ((org-read-date (&rest args) "1999-11-11"))  (org-time-stamp))
          ;;     (insert (concat "   CLOSED: [" (planner-task-date task) " ]")))
          ;;  (flet ((org-read-date (&rest args) '(2 2 2)))  (org-time-stamp t))
          (progn (search-forward ": [")
                 (flet ((org-read-date (&rest args)
                                       (date-to-time (concat (replace-regexp-in-string "\\." "-" (planner-task-date task))    " 00:00" ))))
                   (org-time-stamp nil t))))
      (org-priority (aref  (planner-task-priority task) 0)))))


(defun pof-convert-next-planner-task ()
  (interactive)
  (search-forward-regexp "^#[ABC][0-9]* ")
  (pof-planner-task-to-org-task))

;;finding tasks to edit can be done with (rgrep "^#[ABC] " [a-zA-Z]*.org)
;; issues:
;; - planner tasks with no date
;; - planner tasks on more than one page, day page and project page specifically
;;   - keep task on project page
;;   - delete task on day page
;; - closed planner task on day page should have the pages date
(defun pof-guess-task-date ()
  ;;(date-to-time (concat (pof-guess-task-date) " 00:00"))                     
  (replace-regexp-in-string "\\." "-" (muse-path-sans-extension (muse-page-name))))


(defun pof-demote-buffer ()
  (interactive)
  (pof-fix-headers)
  (org-map-entries (lambda () (org-demote))
                   nil 'file 'inkorg-select-skip)
  (goto-char (point-min))
  (insert (concat "* " (muse-path-sans-extension (muse-page-name)) "\n"))
  (goto-char (point-max))
  (insert "\n"))

(defun pof-merge-dired-files (tobuffer)
  (interactive "Bdestination buffer:")
  (dired-map-over-marks
   (save-excursion
     (let
         ((frombuffer))
       (dired-find-file)
       (setq frombuffer (current-buffer))
       (pof-demote-buffer)
       (switch-to-buffer tobuffer)
       (goto-char (point-max))
       (insert "\n")
       (insert-buffer frombuffer)))
   
   nil))

  

(defun pof-fix-headers ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\\(^*+\\)\\([^* ]\\)" nil t)
      (replace-match "\\1 \\2" nil nil))))

(defun pof-remove-empty-headers ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward
           "^*+ \\(Tasks\\|Schedule\\|Notes\\)[ 
]*\\(^*+\\)" nil t)
      (replace-match "\\2" nil nil)
      (beginning-of-line))))

;;for slurping bbdb to org. The code is mostly just pinched from bbdb and
;; modified to produce org output rather than bbdbs usual display

(defun pof-bbdb-slurp ()
  (interactive)
  (flet ((bbdb-format-record-layout-multi-line (layout record field-list) ( pof-bbdb-format-record-layout-multi-line layout record field-list))
         (bbdb-format-record-name-company (record) ( pof-bbdb-format-record-name-company record))))
  (bbdb "" nil)
  )

(defun pof-bbdb-format-record-name-company (record)
  (let ((name (or (bbdb-record-name record) "???"))
        (company (bbdb-record-company record))
        (start (point)))

    (insert (format "* %s\n" name))
    (insert ":PROPERTIES:")
    (when company
      (insert ":COMPANY:")
      (setq start (point))
      (insert company)
      (put-text-property start (point) 'bbdb-field '(company)))))

(defun pof-bbdb-format-record-layout-multi-line (layout record field-list)
  "Record formatting function for the multi-line layout.
See `bbdb-display-layout-alist' for more."
  (bbdb-format-record-name-company record)
  (insert "\n")
  (let* ((notes (bbdb-record-raw-notes record))
         (indent (or (bbdb-display-layout-get-option layout 'indentation) 14))
         ;;         (fmt (format " %%%ds: " indent))
         (fmt ":%s:")
         start field)
    (if (stringp notes)
        (setq notes (list (cons 'notes notes))))
    (while field-list
      (setq field (car field-list)
            start (point))
      (cond ((eq field 'phones)
             (let ((phones (bbdb-record-phones record))
                   loc phone)
               (while phones
                 (setq phone (car phones)
                       start (point))
                 (setq loc (format fmt (bbdb-phone-location phone)))
                 (insert (format ":loc:%s" loc))
                 (put-text-property start (point) 'bbdb-field
                                    (list 'phone phone 'field-name))
                 (setq start (point))
                 (insert (bbdb-phone-string phone) "\n")
                 (put-text-property start (point) 'bbdb-field
                                    (list 'phone phone
                                          (bbdb-phone-location phone)))
                 (setq phones (cdr phones))))
             (setq start nil))
            ((eq field 'addresses)
             (let ((addrs (bbdb-record-addresses record))
                   loc addr)
               (while addrs
                 (setq addr (car addrs)
                       start (point))
                 (setq loc (format fmt (bbdb-address-location addr)))
                 (insert loc)
                 (put-text-property start (point) 'bbdb-field
                                    (list 'address addr 'field-name))
                 (setq start (point))
                 (bbdb-format-address addr nil indent)
                 (put-text-property start (point) 'bbdb-field
                                    (list 'address addr
                                          (bbdb-address-location addr)))
                 (setq addrs (cdr addrs))))
             (setq start nil))
            ((eq field 'net)
             (let ((net (bbdb-record-net record)))
               (when net
                 (insert (format fmt "EMAIL"))
                 ;;    (put-text-property start (point) 'bbdb-field   '(net field-name))
                 (setq start (point))
         (if (bbdb-display-layout-get-option layout 'primary)
             (insert (car net) "\n")
           (insert (mapconcat (function identity) net ", ") "\n"))
                 (put-text-property start (point) 'bbdb-field '(net)))))
            
            ((eq field 'aka)
             (let ((aka (bbdb-record-aka record)))
               (when aka
                 (insert (format fmt "AKA"))
                 (put-text-property start (point) 'bbdb-field
                                    '(aka field-name))
                 (insert (mapconcat (function identity) aka ", ") "\n")
                 (setq start (point))
                 (put-text-property start (point) 'bbdb-field '(aka)))))

            ((eq field 'notes)
             (let ((notes (bbdb-record-notes record)))
               (when notes
                 ;;                 (insert (format fmt "INSERT LATER NOTES"))
                 ;;                 (insert notes "\n")
                 )))

            
            (t
             (let ((note (assoc field notes))
                   (indent (length (format fmt "")))
                   p notefun)
               (when note
                 (insert (format fmt field))
                 (put-text-property start (point) 'bbdb-field
                                    (list 'property note 'field-name))
                 (setq start (point))
                 (setq p (point)
                       notefun (intern (format "bbdb-format-record-%s" field)))

                 (if nil;;                     (fboundp notefun)
                     (insert (funcall notefun (cdr note)))
                   (insert (cdr note)))
                 
                 (insert "\n\n"))
               )))


      (setq field-list (cdr field-list)))
          (insert ":END:\n")
          (if (bbdb-record-notes record) (insert (bbdb-record-notes record) ))
          (insert "\n")
    ))

(provide 'pof)
