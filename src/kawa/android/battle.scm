(require 'android-defs)
(require 'list-lib)
(require "util.scm")

(define *scroller* ::android.widget.ScrollView #!null)
(define *display* ::android.widget.TextView #!null)
(define *input* ::android.widget.EditText #!null)
(define *enter* ::android.widget.Button #!null)

(activity
 battle
 (on-create
  ((this):setContentView kawa.android.R$layout:main)
  (set! *scroller* ((this):findViewById kawa.android.R$id:scroller))
  (set! *display* ((this):findViewById kawa.android.R$id:display))
  (set! *input* ((this):findViewById kawa.android.R$id:input))
  (set! *enter* ((this):findViewById kawa.android.R$id:enter))
  (new-game)))

(define (onEnter v ::android.view.View)
  (*input-fn* *input*:text)
  (*input*:setText ""))

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
  (new-turn)
  (*enter*:setEnabled #t))

(define (new-turn)
  (set! *attacks-left* (inc (quotient (max 0 *agility*) 15)))
  (show-player)
  (new-attack))

(define (end-turn)
  (dolist (f ::foe *foes*)
  	  (unless (foe-dead? f)
            (f:attack)))
  (if (or (player-dead?) (foes-dead?))
      (end-game)
      (new-turn)))

(define (end-game)
  (when (player-dead?)
	(output "\nYou have been killed. Game over."))
  (when (foes-dead?)
	(output "\nCongratulations! You have vanquished all foes."))
  (*enter*:setEnabled #f))

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
  (case (read-string input)
   ((k) (let ((x (+ 2 (randval (quotient *strength* 2)))))
          (output "Your ki strike has a strength of " x "\n")
          (output "Foe #:\n")
          (set! *attack-strength* x)
          (set! *input-fn* last-strike)))
   ((d) (let ((x (randval (quotient *strength* 6))))
          (output "Your dual strike has a strength of " x "\n")
          (output "Foe #:\n")
          (set! *attack-strength* x)
          (set! *input-fn* first-strike)))
   ((f) (begin
          (dotimes (_ (inc (randval (quotient *strength* 3))))
                   (unless (foes-dead?)
                     ((random-foe):hit 1)))
          (end-attack)))
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
  (let ((f (rand-nth *foes*)))
    (if (foe-dead? f)
	(random-foe)
	f)))

(define (pick-foe x) ::foe
  (if (not (and (integer? x) (>= x 1) (<= x *foes-num*)))
      (begin (output "That is not a valid foe number.\n")
	     (output "Foe #:\n")
	     #!null)
      (let ((f (list-ref *foes* (dec x))))
	(if (foe-dead? f)
	    (begin (output "That foe is already dead.\n")
		   (output "Foe #:\n")
		   #!null)
	    f))))

;; Foe management functions
(define (init-foes)
  (set! *foe-builders* (list orc hydra slime brigand))
  (let ((init-random-foe (lambda (_) ((rand-nth *foe-builders*)))))
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
   (str "A fierce " (type-of (this))))
  ((attack) #!abstract))

(define-simple-class orc (foe)
  (club-level)
  ((*init*)
   (invoke-special foe (this) '*init*)
   (set! club-level (randval 8)))
  ((show)
   (str "A wicked orc with a level " club-level " club"))
  ((attack)
   (let ((x (randval club-level)))
     (output "An orc clubs you and knocks off " x " of your health!\n")
     (set! *health* (- *health* x)))))

(define-simple-class hydra (foe)
  ((show)
   (str "A malicious hydra with " health " heads"))
  ((hit x)
   (set! health (- health x))
   (if (foe-dead? (this))
       (output "The fully decapitated hydra falls to the floor!\n")
       (output "You knock off " x " of the hydra's heads!\n")))
  ((attack)
   (let ((x (randval (quotient health 2))))
     (output "A hydra attacks you with " x " of its heads!\n")
     (output "It also grows back 1 more head!\n")
     (set! health (inc health))
     (set! *health* (- *health* x)))))

(define-simple-class slime (foe)
  (sliminess)
  ((*init*)
   (invoke-special foe (this) '*init*)
   (set! sliminess (randval 5)))
  ((show)
   (str "A slime with a sliminess of " sliminess))
  ((attack)
   (let ((x (randval sliminess)))
     (output "A slime wraps your legs and takes away " x " agility!\n")
     (set! *agility* (- *agility* x))
     (when (zero? (rand-int 2))
	   (output "It also squirts your face, taking away 1 health!\n")
	   (set! *health* (dec *health*))))))

(define-simple-class brigand (foe)
  ((attack)
   (let ((x (max *health* *agility* *strength*)))
     (cond ((= x *health*)
	    (output "A brigand hits with his slingshot for 2 health!\n")
	    (set! *health* (- *health* 2)))
	   ((= x *agility*)
	    (output "A brigand whips your leg for 2 agility!\n")
	    (set! *agility* (- *agility* 2)))
	   ((= x *strength*)
	    (output "A brigand whips your arm for 2 strength!\n")
	    (set! *strength* (- *strength* 2)))))))
