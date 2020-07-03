# Live-Scripting

##  Introduction
Live-Scripting is an approach to combine work in IT projects, documentation and retrieval. 
Very much like test-driven development, live-scripting documents work in command shells, while doing it.
##  The Problem
Since more than 30 years, and even now, IT-work in many case is command shell centric. For many IP professionals the bash or other shells constitute a major part of there work. Often quite sophisticated commands are constructed during problem resolution. Normally these commands are deleted at the end of a session. When similar problems arise days or weeks later, often very similar analysis and solutions steps are pursued again. If documentation of the work is required, it is usually an extra time consuming task. It would be nice if we could document this work in an easy way for ourselves and others. This must include an  easy and effective search method to quickly find previous solutions.
## The live-scripting approach
Live-scripting is a work methodology based on emacs, which documents work on the command shell while doing it. Instead of entering and executing one command at a time, in live-scripting we use two windows side by side: An editor and a shell. The commands in the editor can then be executed with single key shortcut in the adjacent shell. This similar to a debugging session where can step through code, but more simple. In the editor we can jump between commands, repeat them in any order we like, duplicate and modify them. The editor is saved into a text file at the end of the session. 

## Emacs org-mode
Emacs is the ideal tool for it. The ansi-term provides for a robust shell interface within emacs. Since it is an programmable environment the functions to send a line of code to the ansi-term can easily be added. Furthermore the org-mode module is an emacs killer app on its own, adding many features to organize, format and publish the work. The the very heart, org-mode is a mark-up language similar to markdown, put much more powerful. Emacs provides elaborated search capabilities across files and projects. The magit module is a highly praised interface to git. The fact that most files are plain text invites the storage in a source code control system like git. But org-mode an also handle pictures to add screenshots and other attachments for other file types like PDFs. org-mode together with a couple of other emacs modules constitute a cross-media publishing machine which makes it very easy to export to HTML, PDF, Markdown, Confluence, and more. 

## Multi Project Website 
Live-scripting, as it is presented here, is a configuration that spans multiple projects and publishes the org-files and attachments to a single static website. This can be used locally or be synchronized to an web server in an intranet or on the internet. The web site contains a search pages for the whole site based on lunr, which provides a full text search index to find information across different pages and projects.  


Project website: http://live-scripting.s3-website.eu-central-1.amazonaws.com/live-scripting/live-scripting.html

