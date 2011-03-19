(require 'android-defs)
(require 'list-lib)

(define *scroller* ::android.widget.ScrollView #!null)
(define *display* ::android.widget.TextView #!null)
(define *input* ::android.widget.EditText #!null)

(activity
 battle
 (on-create
  ((this):setContentView kawa.android.R$layout:main)
  (set! *scroller* ((this):findViewById kawa.android.R$id:scroller))
  (set! *display* ((this):findViewById kawa.android.R$id:display))
  (set! *input* ((this):findViewById kawa.android.R$id:input))
  (new-game)))

(define (onEnter v ::android.view.View)
  (show (string-append *input*:text "\n")))

(define (show text)
  (*display*:append text)
  (*scroller*:post
   (lambda ()
     (*scroller*:fullScroll android.widget.ScrollView:FOCUS_DOWN))))

;; Global variables
(define *health* #f)
(define *agility* #f)
(define *strength* #f)

(define *foes* '())
(define *foe-builders* '())
(define *foes-num* 12)

(define *attacks-left* #f)
(define *attack-strength* #f)

;; Main game functions
(define (new-game)
  (init-player)
  ;;  (init-foes)
  (new-turn))

(define (new-turn)
  (set! *attacks-left* (+ 1 (quotient (max 0 *agility*) 15)))
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
