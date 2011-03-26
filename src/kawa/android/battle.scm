(require 'android-defs)
(require 'list-lib)
(require "util.scm")

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

(define (output . xs)
  (*display*:append (apply str xs))
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
(define *input-fn* #f)

;; Main game functions
(define (new-game)
  (init-player)
  (init-foes)
  (new-turn))

(define (new-turn)
  (set! *attacks-left* (inc (quotient (max 0 *agility*) 15)))
  (show-player)
  (new-attack))

(define (end-turn)
  ;;  (dolist (f ::foe *foes*)
  ;;	  (unless (foe-dead? f)
  ;;		  (f:attack)))
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
  (output "\nYou are a mystic monk with " *health* " health, ")
  (output *agility* " agility, and " *strength* " strength.\n"))

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
      (output "Your ki strike has a strength of " x "\n")
      (output "Foe #:\n")
      (set! *attack-strength* x)
      (set! *input-fn* last-strike)))
   ((string=? input "d")
    (let ((x (randval (quotient *strength* 6))))
      (output "Your dual strike has a strength of " x "\n")
      (output "Foe #:\n")
      (set! *attack-strength* x)
      (set! *input-fn* first-strike)))
   ((string=? input "f")
    (dotimes (_ (inc (randval (quotient *strength* 3))))
	     (unless (foes-dead?)
		     ((random-foe):hit 1)))
    (end-attack))
   (else (show-attacks))))

(define (first-strike input)
  (let ((f (pick-foe (string->number input))))
    (unless (nil? f)
	    (f:hit *attack-strength*)
	    (if (foes-dead?)
		(end-attack)
		(begin
		  (output "Foe #:\n")
		  (set! *input-fn* last-strike))))))

(define (last-strike input)
  (let ((f (pick-foe (string->number input))))
    (unless (nil? f)
	    (f:hit *attack-strength*)
	    (end-attack))))

(define (end-attack)
  (set! *attacks-left* (dec *attacks-left*))
  (if (or (zero? *attacks-left*) (foes-dead?))
      (end-turn)
      (new-attack)))

(define (randval n)
  (inc (rand-int (max 1 n))))

;; Helper functions for player attacks
(define (random-foe) ::foe
  (let ((f (rand-nth-list *foes*)))
    (if (foe-dead? f)
	(random-foe)
	f)))

(define (pick-foe x) ::foe
  (if (not (and (integer? x) (>= x 1) (<= x *foes-num*)))
      (begin (output "That is not a valid foe number.\n")
	     (output "Foe #:\n")
	     #!null)
      (let ((foe (list-ref *foes* (dec x))))
	(if (foe-dead? foe)
	    (begin (output "That foe is already dead.\n")
		   (output "Foe #:\n")
		   #!null)
	    foe))))

;; Foe management functions
(define (init-foes)
  (set! *foe-builders* (list orc hydra slime brigand))
  (let ((init-random-foe (lambda (_) ((rand-nth-list *foe-builders*)))))
    (set! *foes* (list-tabulate *foes-num* init-random-foe))))

(define (foe-dead? f ::foe)
  (<= f:health 0))

(define (foes-dead?)
  (every foe-dead? *foes*))

(define (show-foes)
  (output "Your foes:\n")
  (dolist (x (iota *foes-num*))
	  (let ((f ::foe (list-ref *foes* x)))
	    (output (inc x) ". ")
	    (if (foe-dead? f)
		(output "**dead**\n")
		(output "(Health = " f:health ") " (f:show) "\n")))))

;; Foes
(define-simple-class foe ()
  (health)
  ((*init*)
   (set! health (randval 10)))
  ((hit x)
   (set! health (- health x))
   (if (foe-dead? (this))
       (output "You killed the " (type-of (this)) "!\n")
       (output "You hit the " (type-of (this)) " for " x " health!\n")))
  ((show)
   (str "A fierce " (type-of (this)))))

(define-simple-class orc (foe)
  (club-level)
  ((*init*)
   (invoke-special foe (this) '*init*)
   (set! club-level (randval 8)))
  ((show)
   (str "A wicked orc with a level " club-level " club")))

(define-simple-class hydra (foe)
  ((show)
   (str "A malicious hydra with " health " heads"))
  ((hit x)
   (set! health (- health x))
   (if (foe-dead? (this))
       (output "The fully decapitated hydra falls to the floor!\n")
       (output "You knock off " x " of the hydra's heads!\n"))))

(define-simple-class slime (foe)
  (sliminess)
  ((*init*)
   (invoke-special foe (this) '*init*)
   (set! sliminess (randval 5)))
  ((show)
   (str "A slime with a sliminess of " sliminess)))

(define-simple-class brigand (foe))
