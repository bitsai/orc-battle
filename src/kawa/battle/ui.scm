(require 'android-defs)
(require "engine.scm")
(require "util.scm")

(define *scroll-view* ::android.widget.ScrollView #!null)
(define *text-view* ::android.widget.TextView #!null)
(define *monster-btn* ::android.widget.Button #!null)

(activity
 ui
 (on-create
  ((this):setContentView kawa.battle.R$layout:main)
  (set! *scroll-view* ((this):findViewById kawa.battle.R$id:scroll_view))
  (set! *text-view* ((this):findViewById kawa.battle.R$id:text_view))
  (set! *monster-btn* ((this):findViewById kawa.battle.R$id:monster_btn))
  (new-game))
 ((onClick v ::android.view.View)
  (process-input (read-string (as android.widget.Button v):text)))
 ((onNextMonster v ::android.view.View)
  (change-monster inc))
 ((onPrevMonster v ::android.view.View)
  (change-monster dec)))

(define (change-monster f)
  (let ((x (string->number *monster-btn*:text)))
    (*monster-btn*:setText (number->string (f x)))))

(define (output . xs)
  (*text-view*:append (apply str xs))
  (*scroll-view*:post
   (lambda ()
     (*scroll-view*:fullScroll android.widget.ScrollView:FOCUS_DOWN))))
