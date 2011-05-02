(require 'android-defs)
(require "engine.scm")
(require "util.scm")

(define *sv* ::android.widget.ScrollView #!null)
(define *outText* ::android.widget.TextView #!null)
(define *targetBtn* ::android.widget.Button #!null)

(activity
 battle
 (on-create
  ((this):setContentView kawa.battle.R$layout:main)
  (set! *sv* ((this):findViewById kawa.battle.R$id:sv))
  (set! *outText* ((this):findViewById kawa.battle.R$id:outText))
  (set! *targetBtn* ((this):findViewById kawa.battle.R$id:target))
  (new-game))
 ((onClick v ::android.view.View)
  (process-input (read-string (as android.widget.Button v):text)))
 ((onNextTarget v ::android.view.View)
  (let ((x (string->number *targetBtn*:text)))
    (*targetBtn*:setText (number->string (inc x)))))
 ((onPrevTarget v ::android.view.View)
  (let ((x (string->number *targetBtn*:text)))
    (*targetBtn*:setText (number->string (dec x))))))

(define (output . xs)
  (*outText*:append (apply str xs))
  (*sv*:post (lambda ()
               (*sv*:fullScroll android.widget.ScrollView:FOCUS_DOWN))))
