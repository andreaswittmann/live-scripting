;; Eval mit C-x C-e am Zeilenende
;; Publisch mit M-x org-publish-project RET org RET

(require 'ox-publish)
(setq org-publish-project-alist
      '(

        ;; create all projects overspanning website

       ("orgweb" :components ("orgweb-notes" "orgweb-static" "orgweb-themes"))


       ("orgweb-notes"
        :base-directory "~/org/"
        :base-extension "org"
        :publishing-directory "/var/www/html/orgweb"
        ;;:exclude ".*"
        ;;:include ["foobar.org"]
        :recursive t
        :publishing-function org-html-publish-to-html
        :headline-levels 4             ; Just the default for this project.
        :auto-preamble t
        :auto-sitemap t                ; Generate sitemap.org automagically...
        :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
        :sitemap-title "Sitemap"         ; ... with title 'Sitemap'.
        )

       ("orgweb-static"
        :base-directory "~/org/"
        :base-extension "css\\|js\\|png\\|jpg\\|jpeg\\|gif\\|pdf\\|txt\\|mp3\\|ogg\\|swf"
        :exclude ".git\\|LICENSE"
        :publishing-directory "/var/www/html/orgweb/"
        :recursive t
        :publishing-function org-publish-attachment
        )

       ("orgweb-themes"
        :base-directory "~/org/aw-org-html-themes/styles"
        :base-extension "css\\|js\\|png\\|jpg\\|jpeg\\|gif\\|pdf\\|txt\\|mp3\\|ogg\\|swf"
        :exclude ".git\\|LICENSE"
        :publishing-directory "/var/www/html/orgweb/styles"
        :recursive t
        :publishing-function org-publish-attachment
        )

       ))

