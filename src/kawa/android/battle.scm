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
  (output (string-append *input*:text "\n")))

(define (output x)
  (let ((o (open-output-string)))
    (display x o)
    (*display*:append (get-output-string o))
    (*scroller*:post
     (lambda ()
       (*scroller*:fullScroll android.widget.ScrollView:FOCUS_DOWN)))))

;; Global variables
(define *health* #f)
(define *agility* #f)
(define *strength* #f)

(define *foes* '())
(define *foe-builders* '())
(define *foes-num* 12)

(define *attacks-left* #f)
(define *attack-strength* #f)

;; Utility functions
(define (random n)
  (*:nextInt (java.util.Random) (as int n)))

;; Main game functions
(define (new-game)
  (init-player)
  (init-foes)
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
  (output "\nYou are a mystic monk with ")
  (output *health*)
  (output " health, ")
  (output *agility*)
  (output " agility, and ")
  (output *strength*)
  (output " strength.\n"))

(define (new-attack)
  (show-foes)
  (show-attacks))

(define (show-attacks)
  (output "Attack style: [k]i strike [d]ual strike [f]lurry of blows\n"))

(define (randval n)
  (+ 1 (random (max 1 n))))

;; Foe management functions
(define (init-foes)
  (set! *foe-builders* (list orc hydra slime brigand))
  (let ((build-foe (lambda (x)
		     ((list-ref
		       *foe-builders*
		       (random (length *foe-builders*)))))))
    (set! *foes* (list-tabulate *foes-num* build-foe))))

(define (foe-dead? f ::foe)
  (<= f:health 0))

(define (show-foes)
  (output "Your foes:\n")
  (for-each (lambda (x)
	      (let ((f ::foe (list-ref *foes* x)))
		(output (+ x 1))
		(output ". ")
		(if (foe-dead? f)
		    (output "**dead**\n")
		    (begin (output "(Health = ")
			   (output f:health)
			   (output ") ")
			   (f:show)))))
	    (list-tabulate *foes-num* values)))

;; Foes
(define-simple-class foe ()
  (health)
  ((*init*)
   (set! health (randval 10)))
  ((show) #!abstract))

(define-simple-class orc (foe)
  (club-level)
  ((*init*)
   (invoke-special foe (this) '*init*)
   (set! club-level (randval 8)))
  ((show)
   (output "A wicked orc with a level ")
   (output club-level)
   (output " club\n")))

(define-simple-class hydra (foe)
  ((show)
   (output "A malicious hydra with ")
   (output health)
   (output " heads\n")))

(define-simple-class slime (foe)
  (sliminess)
  ((*init*)
   (invoke-special foe (this) '*init*)
   (set! sliminess (randval 5)))
  ((show)
   (output "A slime with a sliminess of ")
   (output sliminess)
   (output "\n")))

(define-simple-class brigand (foe)
  ((show)
   (output "A fierce brigand\n")))
