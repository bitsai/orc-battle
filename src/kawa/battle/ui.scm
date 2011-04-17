(require 'android-defs)
(require "engine.scm")
(require "util.scm")

(define *sv* ::android.widget.ScrollView #!null)
(define *outText* ::android.widget.TextView #!null)
(define *inText* ::android.widget.EditText #!null)
(define *imm* ::android.view.inputmethod.InputMethodManager #!null)

(activity
 battle
 (on-create
  ((this):setContentView kawa.battle.R$layout:main)
  (set! *sv* ((this):findViewById kawa.battle.R$id:sv))
  (set! *outText* ((this):findViewById kawa.battle.R$id:outText))
  (set! *inText* ((this):findViewById kawa.battle.R$id:inText))
  (set! *imm* (getSystemService android.content.Context:INPUT_METHOD_SERVICE))
  (new-game))
 ((onClickAttack v ::android.view.View)
  (process-input (read-string (as android.widget.Button v):text)))
 ((onClickEnter v ::android.view.View)
  (process-input (string->number *inText*:text))
  (*inText*:setText "")
  (*imm*:hideSoftInputFromWindow (*inText*:getWindowToken) 0)))

(define (output . xs)
  (*outText*:append (apply str xs))
  (*sv*:post (lambda ()
               (*sv*:fullScroll android.widget.ScrollView:FOCUS_DOWN))))
