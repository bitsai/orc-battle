(require 'list-lib)
(require "game.scm")
(require "monsters.scm")
(require "util.scm")

;; Global variables
(define *player-health* #f)
(define *player-agility* #f)
(define *player-strength* #f)

(define *monsters* '())
(define *monster-builders* '())
(define *monster-num* 12)

(define *input-state* #f)
(define *attacks-left* #f)
(define *hits-left* #f)
(define *hit-strength* #f)

;; Main game functions
(define (new-game)
  (init-monsters)
  (init-player)
  (new-turn)
  (input-loop))

(define (new-turn)
  (show-player)
  (set! *attacks-left* (inc (quotient (max 0 *player-agility*) 15)))
  (pick-attack))

(define (input-loop)
  (process-input (read))
  (input-loop))

(define (process-input input)
  (case *input-state*
    ((pick-attack) (process-attack input))
    ((pick-target) (process-target input))))

(define (end-attack)
  (swap! *attacks-left* dec)
  (if (or (zero? *attacks-left*) (monsters-dead?))
      (end-turn)
      (pick-attack)))

(define (end-turn)
  (dolist (m ::monster (remove monster-dead? *monsters*))
          (m:attack))
  (if (or (player-dead?) (monsters-dead?))
      (end-game)
      (new-turn)))

(define (end-game)
  (when (player-dead?)
	(output "You have been killed. Game over."))
  (when (monsters-dead?)
	(output "Congratulations! You have vanquished all of your foes."))
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

(define (pick-attack)
  (show-monsters)
  (output "Attack style: [k]i strike [d]ual strike [f]lurry of blows")
  (set! *input-state* 'pick-attack))

(define (process-attack input)
  (case input
    ((k) (let ((x (+ 2 (randval (quotient *player-strength* 2)))))
	   (output "Your ki strike has a strength of " x ".\n")
           (set! *hits-left* 1)
	   (set! *hit-strength* x)
           (pick-target)))
    ((d) (let ((x (randval (quotient *player-strength* 6))))
	   (output "Your dual strike has a strength of " x ".\n")
	   (set! *hits-left* 2)
           (set! *hit-strength* x)
           (pick-target)))
    ((f) (begin (dotimes (_ (inc (randval (quotient *player-strength* 3))))
			 (unless (monsters-dead?)
				 ((random-monster):hit 1)))
		(end-attack)))
    (else (output "That is not a valid attack.\n"))))

(define (pick-target)
  (output "Monster #:")
  (set! *input-state* 'pick-target))

(define (process-target input)
  (let ((m (pick-monster input)))
    (unless (eqv? m #!null)
	    (m:hit *hit-strength*)
	    (swap! *hits-left* dec)
	    (if (or (zero? *hits-left*) (monsters-dead?))
		(end-attack)
		(pick-target)))))

;; Helper functions for player attacks
(define (random-monster) ::monster
  (let ((m (rand-nth *monsters*)))
    (if (monster-dead? m)
	(random-monster)
	m)))

(define (pick-monster x) ::monster
  (if (not (and (integer? x) (>= x 1) (<= x *monster-num*)))
      (begin (output "That is not a valid monster number.\n")
	     #!null)
      (let ((m (list-ref *monsters* (dec x))))
	(if (monster-dead? m)
	    (begin (output "That monster is already dead.\n")
		   #!null)
	    m))))

;; Monster management functions
(define (init-monsters)
  (set! *monster-builders* (list orc hydra slime brigand))
  (let ((init-rand-monster (lambda (_) ((rand-nth *monster-builders*)))))
    (set! *monsters* (list-tabulate *monster-num* init-rand-monster))))

(define (monster-dead? m ::monster)
  (<= m:health 0))

(define (monsters-dead?)
  (every monster-dead? *monsters*))

(define (show-monsters)
  (output "Your foes:\n")
  (dolist (x (iota *monster-num*))
	  (let ((m ::monster (list-ref *monsters* x)))
	    (output "  " (inc x) ". ")
	    (if (monster-dead? m)
		(output "**dead**\n")
		(output "(Health = " m:health ") " (m:show) "\n")))))
