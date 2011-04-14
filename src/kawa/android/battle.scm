(require 'android-defs)
(require "engine.scm")
(require "util.scm")

(define *sv* ::android.widget.ScrollView #!null)
(define *tv* ::android.widget.TextView #!null)
(define *input* ::android.widget.EditText #!null)

(activity
 battle
 (on-create
  ((this):setContentView kawa.android.R$layout:main)
  (set! *sv* ((this):findViewById kawa.android.R$id:sv))
  (set! *tv* ((this):findViewById kawa.android.R$id:tv))
  (set! *input* ((this):findViewById kawa.android.R$id:input))
  (new-game)))

(define (ki v ::android.view.View)
  (process-input 'k))

(define (dual v ::android.view.View)
  (process-input 'd))

(define (flurry v ::android.view.View)
  (process-input 'f))

(define (enter v ::android.view.View)
  (process-input (string->number *input*:text))
  (*input*:setText ""))

(define (output . xs)
  (*tv*:append (apply str xs))
  (*sv*:post
   (lambda ()
     (*sv*:fullScroll android.widget.ScrollView:FOCUS_DOWN))))
