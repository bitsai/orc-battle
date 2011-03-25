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
  (*input-fn* *input*:text))

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
(define *input-fn* #f)

;; Utility functions
(define (random n)
  (*:nextInt (java.util.Random) (as int n)))

(define (type-of obj)
  (let ((n (*:getName (*:getClass obj))))
    (substring n (string-length "kawa.android.") (string-length n))))

(define-syntax dotimes
  (syntax-rules ()
    ((dotimes (counter init) body ...)
     (do ((max init)
	  (counter 0 (+ counter 1)))
	 ((= counter max))
       body ...))))

;; Main game functions
(define (new-game)
  (init-player)
  (init-foes)
  (new-turn))

(define (new-turn)
  (set! *attacks-left* (+ 1 (quotient (max 0 *agility*) 15)))
  (show-player)
  (new-attack))

(define (end-turn)
  ;;  (for-each (lambda (f ::foe)
  ;;	      (unless (foe-dead? f)
  ;;		      (f:attack)))
  ;;	    *foes*)
  (if (or (player-dead?) (foes-dead?))
      (end-game)
      (new-turn)))

(define (end-game)
  (when (player-dead?)
	(output "\nYou have been killed. Game over."))
  (when (foes-dead?)
	(output "\nCongratulations! You have vanquished all foes.")))

;; Player management functions
(define (init-player)
  (set! *health* 30)
  (set! *agility* 30)
  (set! *strength* 30))

(define (player-dead?)
  (<= *health* 0))

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
  (show-attacks)
  (set! *input-fn* player-attack))

(define (show-attacks)
  (output "Attack style: [k]i strike [d]ual strike [f]lurry of blows\n"))

(define (player-attack input)
  (cond
   ((string=? input "k")
    (let ((x (+ 2 (randval (quotient *strength* 2)))))
      (output "Your ki strike has a strength of ")
      (output x)
      (output "\nFoe #:\n")
      (set! *attack-strength* x)
      (set! *input-fn* last-strike)))
   ((string=? input "d")
    (let ((x (randval (quotient *strength* 6))))
      (output "Your dual strike has a strength of ")
      (output x)
      (output "\nFoe #:\n")
      (set! *attack-strength* x)
      (set! *input-fn* first-strike)))
   ((string=? input "f")
    (dotimes (x (+ 1 (randval (quotient *strength* 3))))
	     (unless (foes-dead?)
		     ((random-foe):hit 1)))
    (end-attack))
   (else (show-attacks))))

(define (first-strike input)
  (let ((f (pick-foe (string->number input))))
    (unless (eqv? #!null f)
	    (f:hit *attack-strength*)
	    (if (not (foes-dead?))
		(begin
		  (output "Foe #:\n")
		  (set! *input-fn* last-strike))
		(end-attack)))))

(define (last-strike input)
  (let ((f (pick-foe (string->number input))))
    (unless (eqv? #!null f)
	    (f:hit *attack-strength*)
	    (end-attack))))

(define (end-attack)
  (set! *attacks-left* (- *attacks-left* 1))
  (if (or (zero? *attacks-left*) (foes-dead?))
      (end-turn)
      (new-attack)))

(define (randval n)
  (+ 1 (random (max 1 n))))

;; Helper functions for player attacks
(define (random-foe) ::foe
  (let ((f (list-ref *foes* (random (length *foes*)))))
    (if (foe-dead? f)
	(random-foe)
	f)))

(define (pick-foe x) ::foe
  (if (not (and (integer? x) (>= x 1) (<= x *foes-num*)))
      (begin (output "That is not a valid foe number.\n")
	     (output "Foe #:\n")
	     #!null)
      (let ((foe (list-ref *foes* (- x 1))))
	(if (foe-dead? foe)
	    (begin (output "That foe is already dead.\n")
		   (output "Foe #:\n")
		   #!null)
	    foe))))

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

(define (foes-dead?)
  (every foe-dead? *foes*))

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
  ((hit x)
   (set! health (- health x))
   (if (foe-dead? (this))
       (begin (output "You killed the ")
	      (output (type-of (this)))
	      (output "!\n"))
       (begin (output "You hit the ")
	      (output (type-of (this)))
	      (output ", knocking off ")
	      (output x)
	      (output " health points!\n"))))
  ((show)
   (output "A fierce ")
   (output (type-of (this)))
   (output "\n")))

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
   (output " heads\n"))
  ((hit x)
   (set! health (- health x))
   (if (foe-dead? (this))
       (output "The fully decapitated hydra falls to the floor!\n")
       (begin (output "You knock off ")
	      (output x)
	      (output " of the hydra's heads!\n")))))

(define-simple-class slime (foe)
  (sliminess)
  ((*init*)
   (invoke-special foe (this) '*init*)
   (set! sliminess (randval 5)))
  ((show)
   (output "A slime with a sliminess of ")
   (output sliminess)
   (output "\n")))

(define-simple-class brigand (foe))
