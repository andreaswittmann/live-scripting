;; Eval mit C-x C-e am Zeilenende
;; Publisch mit M-x org-publish-project RET org RET
(package-initialize)
(require 'org)
(require 'ox)
(require 'ox-publish)
;;(require 'htmlize)
;;(require 'ox-html)
(setq org-export-with-broken-links t)
(setq org-html-htmlize-output-type 'css)
(setq org-export-babel-evaluate nil)
;;(setq org-src-fontify-natively t)

(setq org-publish-project-alist
      '(

        ;; create all projects overspanning website
       ("orgweb" :components ("orgweb-notes" "orgweb-static" "orgweb-themes"))


       ("orgweb-notes"
        :base-directory "~/org/"
        :base-extension "org"
        :publishing-directory "/var/www/html/orgweb"
        :exclude "lunr_files"
        ;;:include ["foobar.org"]
        :recursive t
        :publishing-function org-html-publish-to-html
        :headline-levels 4             ; Just the default for this project.
        :auto-preamble t
        :auto-sitemap t                ; Generate sitemap.org automagically...
        :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
        :sitemap-title "Sitemap"         ; ... with title 'Sitemap'.
        )

       ("orgweb-index"
        :base-directory "~/org/"
        :base-extension "org"
        :publishing-directory "/var/www/html/orgweb"
        :exclude ".*"
        :include ["index.org"]
        :recursive nil
        :publishing-function org-html-publish-to-html
        :headline-levels 4             ; Just the default for this project.
        :auto-preamble t
        :auto-sitemap nil               ; Generate sitemap.org automagically...
        )

       ("orgweb-static"
        :base-directory "~/org"
        :base-extension "css\\|js\\|png\\|jpg\\|jpeg\\|gif\\|pdf\\|txt\\|mp3\\|ogg\\|swf"
        :exclude ".git\\|LICENSE"
        :publishing-directory "/var/www/html/orgweb"
        :recursive t
        :publishing-function org-publish-attachment
        )


       ("orgweb-themes"
        ;; copy the contents of the style folder to the style folder at the web root.
        ;; Then create links on every level.
        :base-directory "~/org/aw-org-html-themes/styles"
        :base-extension "css\\|js\\|png\\|jpg\\|jpeg\\|gif\\|pdf\\|txt\\|mp3\\|ogg\\|swf"
        :exclude ".git\\|LICENSE"
        :publishing-directory "/var/www/html/orgweb/styles"
        :completion-function fixStyleFolder
        :recursive t
        :publishing-function org-publish-attachment
        )
       ))
;; Function to Handle style folder
(defun fixStyleFolder (projectPropertyList)
  "This function calls a shell function to fix the style folder in multi-project websites.
  The local.setup Themes from org-html-themes require a styles directory on in the same folder.
  We call a shell function to takes care of it. "
  (interactive)
  (message "fixStyleFolder called!")
  (setq publishing-directory (plist-get projectPropertyList ':publishing-directory ))
  (shell-command (format "pDIR=%s; echo \"${pDIR}\"" publishing-directory))
  (shell-command (format "bash ~lubuntu/org/live-scripting/bin/publish.sh -c mycopy -d %s" publishing-directory))
)

(defun org-download-link-format-function-aw (filename)
  "The default function of `org-download-link-format-function'."
  (message "called: org-download-link-format-function-aw")
  (if (and (>= (string-to-number org-version) 9.3)
           (eq org-download-method 'attach))
      (format "[[attachment:%s]]\n"
              (org-link-escape
               (file-relative-name filename (org-attach-dir))))
    (setq abbr-filename (org-link-escape
                          (funcall org-download-abbreviate-filename-function filename)))
    (format "[[file:%s][file:%s]]\n" abbr-filename abbr-filename
           )))

