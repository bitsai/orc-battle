(require 'android-defs)
(require 'list-lib)

(define *display* ::android.widget.TextView #!null)
(define *scroller* ::android.widget.ScrollView #!null)
(define *input* ::android.widget.EditText #!null)

(activity
 battle
 (on-create
  ((this):setContentView kawa.android.R$layout:main)
  (set! *display* (as <android.widget.TextView>
		      ((this):findViewById kawa.android.R$id:display)))
  (set! *scroller* (as <android.widget.ScrollView>
		       ((this):findViewById kawa.android.R$id:scroller)))
  (set! *input* (as <android.widget.EditText>
		    ((this):findViewById kawa.android.R$id:input)))
  (new-game)))

(define (onEnter (v ::android.view.View)) ::void
  (show (string-append *input*:text "\n")))

(define (show text ::string) ::void
  (*display*:append text)
  (*scroller*:post
   (lambda ()
     (*scroller*:fullScroll android.widget.ScrollView:FOCUS_DOWN))))

;; Global variables
(define *health* ::integer #!null)
(define *agility* ::integer #!null)
(define *strength* ::integer #!null)

(define *foes* ::list '())
(define *foe-builders* ::list '())
(define *foes-num* ::integer 12)

(define *attacks-left* ::integer #!null)
(define *attack-strength* ::integer #!null)

;; Main game functions
(define (new-game)
  (init-player)
  ;;  (init-foes)
  (new-turn))

(define (new-turn)
  (let ((x (as <integer> (max 0 *agility*))))
    (set! *attacks-left* (+ 1 (quotient x 15))))
  (show-player)
  (new-attack))

;; Player management functions
(define (init-player)
  (set! *health* 30)
  (set! *agility* 30)
  (set! *strength* 30))

(define (show-player)
  (show "\nYou are a mystic monk with ")
  (show (number->string *health*))
  (show " health, ")
  (show (number->string *agility*))
  (show " agility, and ")
  (show (number->string *strength*))
  (show " strength.\n"))

(define (new-attack)
  ;;  (show-foes)
  (show-attacks))

(define (show-attacks)
  (show "Attack style: [k]i strike [d]ual strike [f]lurry of blows\n"))
