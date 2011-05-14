(require 'android-defs)
(require "engine.scm")
(require "util.scm")

(define *sv* ::android.widget.ScrollView #!null)
(define *outText* ::android.widget.TextView #!null)
(define *monsterBtn* ::android.widget.Button #!null)

(activity
 battle
 (on-create
  ((this):setContentView kawa.battle.R$layout:main)
  (set! *sv* ((this):findViewById kawa.battle.R$id:sv))
  (set! *outText* ((this):findViewById kawa.battle.R$id:outText))
  (set! *monsterBtn* ((this):findViewById kawa.battle.R$id:monsterBtn))
  (new-game))
 ((onClick v ::android.view.View)
  (process-input (read-string (as android.widget.Button v):text)))
 ((onNextMonster v ::android.view.View)
  (change-monster inc))
 ((onPrevMonster v ::android.view.View)
  (change-monster dec)))

(define (change-monster f)
  (let ((x (string->number *monsterBtn*:text)))
    (*monsterBtn*:setText (number->string (f x)))))

(define (output . xs)
  (*outText*:append (apply str xs))
  (*sv*:post (lambda ()
               (*sv*:fullScroll android.widget.ScrollView:FOCUS_DOWN))))
