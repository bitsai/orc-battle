(require 'android-defs)
(require "engine.scm")
(require "util.scm")

(define-alias Button android.widget.Button)
(define-alias EditText android.widget.EditText)
(define-alias ScrollView android.widget.ScrollView)
(define-alias TextView android.widget.TextView)
(define-alias View android.view.View)

(define *sv* ::ScrollView #!null)
(define *outText* ::TextView #!null)

(activity
 battle
 (on-create
  ((this):setContentView kawa.battle.R$layout:main)
  (set! *sv* ((this):findViewById kawa.battle.R$id:sv))
  (set! *outText* ((this):findViewById kawa.battle.R$id:outText))
  (new-game))
 ((onClickAttack v ::View)
  (process-input (read-string (as Button v):text)))
 ((onClickEnter v ::View)
  (let ((inText ::EditText ((this):findViewById kawa.battle.R$id:inText)))
    (process-input (string->number inText:text))
    (inText:setText ""))))

(define (output . xs)
  (*outText*:append (apply str xs))
  (*sv*:post (lambda () (*sv*:fullScroll ScrollView:FOCUS_DOWN))))
