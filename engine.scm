(require 'list-lib)
(require "game.scm")
(require "monsters.scm")
(require "util.scm")

;; Global variables
(define *player-health* #f)
(define *player-agility* #f)
(define *player-strength* #f)

(define *foes* '())
(define *foe-builders* '())
(define *foes-num* 12)

(define *attacks-left* #f)
(define *strikes-left* #f)
(define *strike-strength* #f)
(define *input-state* #f)

;; Main game functions
(define (new-game)
  (init-player)
  (init-foes)
  (new-turn)
  (input-loop))

(define (new-turn)
  (show-player)
  (set! *attacks-left* (inc (quotient (max 0 *player-agility*) 15)))
  (new-attack))

(define (input-loop)
  (input-fn (read))
  (input-loop))

(define (input-fn input)
  (case *input-state*
    ((choose-attack) (choose-attack input))
    ((choose-target) (choose-target input))))

(define (end-turn)
  (dolist (f ::foe *foes*)
	  (unless (f:dead?)
		  (output (f:attack))))
  (if (or (player-dead?) (foes-dead?))
      (end-game)
      (new-turn)))

(define (end-game)
  (when (player-dead?)
	(output "You have been killed. Game over."))
  (when (foes-dead?)
	(output "Congratulations! You have vanquished all foes."))
  (exit))

;; Player management functions
(define (init-player)
  (set! *player-health* 30)
  (set! *player-agility* 30)
  (set! *player-strength* 30))

(define (player-dead?)
  (<= *player-health* 0))

(define (show-player)
  (output "You are a mystic monk with "
	  *player-health* " health, "
	  *player-agility* " agility, and "
	  *player-strength* " strength.\n"))

(define (new-attack)
  (show-foes)
  (show-attacks)
  (set! *input-state* 'choose-attack))

(define (show-attacks)
  (output "Attack style: [k]i strike [d]ual strike [f]lurry of blows"))

(define (choose-attack input)
  (case input
    ((k) (let ((x (+ 2 (randval (quotient *player-strength* 2)))))
	   (output "Your ki strike has a strength of " x "\n")
	   (output "Foe #:")
	   (set! *strikes-left* 1)
	   (set! *strike-strength* x)
	   (set! *input-state* 'choose-target)))
    ((d) (let ((x (randval (quotient *player-strength* 6))))
	   (output "Your dual strike has a strength of " x "\n")
	   (output "Foe #:")
	   (set! *strikes-left* 2)
	   (set! *strike-strength* x)
	   (set! *input-state* 'choose-target)))
    ((f) (begin (dotimes (_ (inc (randval (quotient *player-strength* 3))))
			 (unless (foes-dead?)
				 (output ((random-foe):hit 1))))
		(end-attack)))
    (else (show-attacks))))

(define (choose-target input)
  (let ((f (get-foe input)))
    (unless (eqv? f #!null)
	    (output (f:hit *strike-strength*))
	    (swap! *strikes-left* dec)
	    (if (or (zero? *strikes-left*) (foes-dead?))
		(end-attack)
		(output "Foe #:")))))

(define (end-attack)
  (swap! *attacks-left* dec)
  (if (or (zero? *attacks-left*) (foes-dead?))
      (end-turn)
      (new-attack)))

;; Helper functions for player attacks
(define (random-foe) ::foe
  (let ((f ::foe (rand-nth *foes*)))
    (if (f:dead?)
	(random-foe)
	f)))

(define (get-foe input) ::foe
  (if (not (and (integer? input) (>= input 1) (<= input *foes-num*)))
      (begin (output "That is not a valid foe number.\n")
	     (output "Foe #:")
	     #!null)
      (let ((f ::foe (list-ref *foes* (dec input))))
	(if (f:dead?)
	    (begin (output "That foe is already dead.\n")
		   (output "Foe #:")
		   #!null)
	    f))))

;; Foe management functions
(define (init-foes)
  (set! *foe-builders* (list orc hydra slime brigand))
  (let ((init-rand-foe (lambda (_) ((rand-nth *foe-builders*)))))
    (set! *foes* (list-tabulate *foes-num* init-rand-foe))))

(define (foes-dead?)
  (every (lambda (f ::foe) (f:dead?)) *foes*))

(define (show-foes)
  (output "Your foes:\n")
  (dolist (x (iota *foes-num*))
	  (let ((f ::foe (list-ref *foes* x)))
	    (output (inc x) ". ")
	    (if (f:dead?)
		(output "**dead**\n")
		(output "(Health = " f:health ") " (f:show) "\n")))))
