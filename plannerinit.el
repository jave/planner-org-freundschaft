;; this file is obsolete
;(setq Info-default-directory-list 
;      (cons "/home/joakim/.emacs.d/jave/emacs-planner/muse/" Info-default-directory-list))
(setq Info-default-directory-list 
      (cons "~/.emacs.d/jave/emacs-planner/planner/" Info-default-directory-list))
(setq Info-default-directory-list 
      (cons "~/.emacs.d/jave/emacs-planner/remember/" Info-default-directory-list))

(my-add-subdirs-to-list (expand-file-name "~/.emacs.d/jave/emacs-planner/") 'load-path)
;(my-add-subdirs-to-list (expand-file-name "~/.emacs.d/jave/emacs-planner/muse/") 'load-path)
(require 'planner)
(require 'muse)
;;;;;;;,
(setq planner-diary-use-appts t)
(setq planner-diary-use-cal-desk t)
(setq planner-diary-use-diary t)

(setq planner-renumber-tasks-automatically t)
(setq planner-sort-tasks-automatically nil)

;;;;;;;;;;;;;; moving to planner-muse

(setq planner-project "Plans")
(setq muse-project-alist
      `(("Plans"        ;; use value of `planner-project'
         (,@(muse-project-alist-dirs "~/Plans"  )  ;;         ;; where your Planner pages are located
          :default "TaskPool" ;; use value of `planner-default-page'
          :major-mode planner-mode
          :visit-link planner-visit-link)

         ;; This next part is for specifying where Planner pages
         ;; should be published and what Muse publishing style to
         ;; use.  In this example, we will use the XHTML publishing
         ;; style.

         (:base "planner-xhtml"
                ;; value of `planner-publishing-directory'
                :path "~/public_html/Plans"))))

;; (setq muse-project-alist
;;       `(("Blog"
;;          (,@(muse-project-alist-dirs "~/proj/wiki/blog")  ;; base dir
;;           :default "guestbook")

;;          ,@(muse-project-alist-styles "~/proj/wiki/blog"  ;; base dir
;;                                       ;; output dir
;;                                       "~/personal-site/site/blog"
;;                                       ;; style
;;                                       "my-blosxom"))))

(require 'muse-mode)
(require 'muse-colors)
(require 'muse-wiki)
(require 'muse-html)
(require 'muse-latex)
(require 'planner-publish)

(require 'planner-multi)

;;;;;;;;;;;;;;;;

;calendar stuff
(load-library "sv-kalender")
(setq view-diary-entries-initially t)
;(calendar)
;(setq view-calendar-holidays-initially t)
(setq mark-holidays-in-calendar t)

;for week numbers
;calendar-intermonth-text



;;
;stuff to add week to calendar
; to modeline
;; (add-to-list 'calendar-mode-line-format
;;              '(let ((day (nth 1 date))
;;                     (month (nth 0 date))
;;                     (year (nth 2 date)))
;;                 (format-time-string "Week of year: %V"
;;                                     (encode-time 1 1 1 day month 
;; year))))
; in calendar, but ed reingold says this sucks.



;(plan)
(setq planner-carry-tasks-forward t)

;(require 'emacs-wiki-table)
(require 'planner-gnus)
(require 'planner-erc)
(setq mark-diary-entries-in-calendar t)
(require 'planner-tasks-overview)

(defun planner-grep-unfinished-tasks ()
  "This is useful for finding both planner tasks and org tasks in one go."
  (interactive)
  ;(grep-compute-defaults);;workaround for rgrep buglet
  ;;oddly, grep must have been run once interactively for this to work
  ;;sadly breaks grep-edit
  ;;support both org and planner
  (let ((grep-find-template "find . <X> -type f <F> -print0 | xargs -0 -e grep <C> -i -nH -e <R>|sort --field-separator='\:' -k3.2,3.2 -k1"))
    (rgrep "\\(\\<TODO\\>\\)\\|\\(^#[ABCDEFGH][0-9]*  *_\\)" "*.muse  *.org" "~/Plans")))


;(global-set-key (kbd "<f9> t") 'planner-create-task-from-buffer)
(global-set-key (kbd "<f9> t") 'planner-grep-unfinished-tasks)
(global-set-key (kbd "<f9> o") 'planner-tasks-overview)
;(global-set-key (kbd "<f9> p") 'plan)

;;try out calfw as calendar. its in gnu elpa
;;(global-set-key (kbd "<f9> c") 'calendar)
(require 'calfw)
(require 'calfw-org)
;;(global-set-key (kbd "<f9> c") 'cfw:open-calendar-buffer)
;;org integration is very nice but it take about 5 seconds to open the buffer for me which is a bit much
(global-set-key (kbd "<f9> c") 'cfw:open-org-calendar)

(global-set-key (kbd "<f9> f") 'muse-project-find-file)


;(require 'planner-auto)

;(require 'planner-diary)
;  (add-hook 'calendar-move-hook 'planner-diary-show-day-plan-or-diary)
;(remove-hook 'calendar-move-hook 'planner-diary-show-day-plan-or-diary t)

;(add-hook 'calendar-move-hook 'planner-calendar-show)
(planner-calendar-insinuate) 
;pretty good, day-planner movement in calender, press "n" on a date to get new page!

;try planner-appt instead of planner-diary for a while
(defun list-diary-entries (x y))
(require 'planner-appt)
(planner-appt-use-tasks-and-schedule)
(planner-appt-insinuate)
(planner-appt-calendar-insinuate)

(setq planner-appt-sort-schedule-on-update-flag t)
(setq planner-appt-update-appts-on-save-flag t)
(setq planner-appt-font-lock-appointments-flag t)

;these go into  "~/.diary.cyclic-tasks"
(require 'planner-cyclic)
(planner-appt-schedule-cyclic-insinuate)

(appt-activate 1); turn reminding on

;(add-to-list 'planner-custom-variables
;             (emacs-wiki-recurse-directories . t))

;stuff for planner wiki heading looks
;  ok, so I shouldnt copy each and every time we open a planner file...
;(require 'emacs-wiki)
(require 'outline)

(defun planner-copy-outline-faces ()
  (copy-face 'outline-1 'emacs-wiki-header-1)
  (copy-face 'outline-2 'emacs-wiki-header-2)
  (copy-face 'outline-3 'emacs-wiki-header-3)
  (copy-face 'outline-4 'emacs-wiki-header-4)
)

(add-hook 'planner-mode-hook 'planner-copy-outline-faces)


(require 'remember-planner)
;;
;;  (autoload 'remember "remember" nil t)
;;  (autoload 'remember-region "remember" nil t)
;;
;;  (define-key global-map [f8] 'remember)
;;  (define-key global-sap [f9] 'remember-region)
;;
;; planner.el users should use `remember-to-planner' instead of `remember'
;; to save more context information.



;'(emacs-wiki-directories (quote ("/home/joakim/Plans")) nil (emacs-wiki))
; '(emacs-wiki-mode-hook (quote (emacs-wiki-use-font-lock table-recognize emacs-wiki-use-font-lock)))

; '(emacs-wiki-recurse-directories t)
; '(emacs-wiki-refresh-file-alist-p nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; jdbc urls
(defun planner-browse-url-jdbc (url)
  "Browse JDBC URLs."
  ;; code for browsing JDBC URLs
  ;; url to test  with:
  (string-match "jdbc:\\([^:/]*\\)://\\([^/]*\\)/\\([^?]*\\).user=\\([^&]*\\)&password=\\(.*\\)" url)
  (let
      ((driver (match-string 1 url))
       (sql-server   (match-string 2 url))
       (sql-database   (match-string 3 url))
       (sql-user   (match-string 4 url))
       (sql-password   (match-string 5 url))
       )
      (message "jdbc url:%s driver:%s host:%s db:%s usr:%s pwd:%s" url driver sql-server sql-database sql-user sql-password)
      (sql-postgres)
      (sql-rename-buffer) ;renames the buffer to something useful
    )
  )


;jdbc:\\([^:/]*\\)://\\([^/]*\\)/\\([^?]*\\).user=\\([^&]*\\)&password=\\(.*\\)
(defun planner-resolve-url-jdbc (url)
  "Resolve JDBC URLs."
  ;; Turn a JDBC URL into an http:// URL, if applicable
  ;; Otherwise omit this and use 'identify below
nil)

(planner-add-protocol "jdbc:" 'planner-browse-url-jdbc
                                'planner-resolve-url-jdbc)

;; So if you activate a url like:
;; jdbc:postgresql://localhost/pgdatabase?user=demo&password=demo

;; it will open that server in sql mode.

;; TODO:
;; - driver is just ignored, should for to the correct postgres/mssql
;; whatever driver function. currently it just does postgres
;; - sql mode prompts for arguments, with the data suplied in the jdbc
;; url as defaults, I would rather not have it prompt.
;; - try to remember if there is a buffer for this url already and optionaly go there instead

;;NOTE see also jdbc-url.el that i wrote should be better.
;;

(planner-install-extra-task-keybindings)

 (require 'muse-backlink)

(provide 'plannerinit)
