(require 'list-lib)
(require "ui.scm")
(require "util.scm")

;; Global variables
(define *player-health* #f)
(define *player-agility* #f)
(define *player-strength* #f)

(define *monsters* '())
(define *monster-builders* '())
(define *monster-num* 12)

(define *input-state* #f)
(define *attacks-remaining* #f)
(define *hits-remaining* #f)
(define *hit-strength* #f)

;; Main game functions
(define (new-game)
  (init-monsters)
  (init-player)
  (new-turn))

(define (new-turn)
  (show-player)
  (set! *attacks-remaining* (inc (quotient (max 0 *player-agility*) 15)))
  (new-attack))

(define (new-attack)
  (show-monsters)
  (get-attack))

(define (process-input input)
  (unless (or (player-dead?) (monsters-dead?))
    (output input)
    (case *input-state*
      ((get-attack) (process-attack input))
      ((get-monster) (process-monster input)))))

(define (end-attack)
  (swap! *attacks-remaining* dec)
  (if (or (zero? *attacks-remaining*) (monsters-dead?))
      (end-turn)
      (new-attack)))

(define (end-turn)
  (unless (monsters-dead?)
    (output "")
    (dolist (m (remove monster-dead? *monsters*))
            ((as monster m):attack)))
  (output "")
  (if (or (player-dead?) (monsters-dead?))
      (end-game)
      (new-turn)))

(define (end-game)
  (when (player-dead?)
    (output "You have been killed. Game over."))
  (when (monsters-dead?)
    (output "Congratulations! You have vanquished all foes.")))

;; Player management functions
(define (init-player)
  (set! *player-health* 30)
  (set! *player-agility* 30)
  (set! *player-strength* 30))

(define (player-dead?)
  (<= *player-health* 0))

(define (show-player)
  (output "Valiant Knight: "
          "(Health " *player-health* ") "
          "(Agility " *player-agility* ") "
          "(Strength " *player-strength* ")"))

(define (get-attack)
  (output "Attack style: [S]tab [D]ouble swing [R]oundhouse")
  (set! *input-state* 'get-attack))

(define (process-attack input)
  (case input
    ((S) (let ((x (+ 2 (randval (quotient *player-strength* 2)))))
	   (output "Your stab has a strength of " x ".")
           (set! *hits-remaining* 1)
	   (set! *hit-strength* x)
           (get-monster)))
    ((D) (let ((x (randval (quotient *player-strength* 6))))
	   (output "Your double swing has a strength of " x ".")
	   (set! *hits-remaining* 2)
           (set! *hit-strength* x)
           (get-monster)))
    ((R) (let ((x (inc (randval (quotient *player-strength* 3)))))
           (dotimes (_ x)
                    (unless (monsters-dead?)
                      ((as monster (random-monster)):hit 1)))
           (end-attack)))
    (else (output "That is not a valid attack.")
          (get-attack))))

(define (randval n)
  (inc (rand-int (max 1 n))))

;; Helper functions for player attacks
(define (get-monster)
  (output "Monster #:")
  (set! *input-state* 'get-monster))

(define (process-monster input)
  (let ((m (as monster (pick-monster input))))
    (unless (eqv? m #!null)
      (m:hit *hit-strength*)
      (swap! *hits-remaining* dec)
      (if (or (zero? *hits-remaining*) (monsters-dead?))
          (end-attack)
          (get-monster)))))

(define (random-monster)
  (let ((m (rand-nth *monsters*)))
    (if (monster-dead? m)
	(random-monster)
	m)))

(define (pick-monster x)
  (if (not (and (integer? x) (<= 1 x *monster-num*)))
      (begin (output "That is not a valid monster number.")
             (get-monster)
             #!null)
      (let ((m (list-ref *monsters* (dec x))))
        (if (monster-dead? m)
            (begin (output "That monster is already dead.")
                   (get-monster)
                   #!null)
            m))))

;; Monster management functions
(define (init-monsters)
  (let* ((build-monster (lambda (_) ((rand-nth *monster-builders*))))
         (new-monsters (list-tabulate *monster-num* build-monster)))
    (set! *monsters* new-monsters)))

(define (monster-dead? m)
  (<= (as monster m):health 0))

(define (monsters-dead?)
  (every monster-dead? *monsters*))

(define (show-monsters)
  (output "Your foes:")
  (dolist (x (iota *monster-num*))
          (let ((m (as monster (list-ref *monsters* x))))
            (output (inc x) ". "
                    (if (monster-dead? m)
                        "**dead**"
                        (str "(Health " m:health ") " (m:show)))))))

;; The Generic Monster
(define (type-of m)
  (let* ((prefix-len (string-length "kawa.battle.orc$Mnbattle$"))
         (suffix-len (string-length "$class"))
         (full-name (*:getName (*:getClass m)))
         (name-end (- (string-length full-name) suffix-len)))
    (substring full-name prefix-len name-end)))

(define-class monster ()
  (health init-form: (randval 10))
  ((hit x)
   (swap! health - x)
   (if (monster-dead? (this))
       (output "You killed the " (type-of (this)) "!")
       (output "You hit the " (type-of (this)) " for " x " health!")))
  ((show)
   (str "A fierce " (type-of (this))))
  ((attack)
   #!abstract))

;; The Wicked Orc
(define-class orc (monster)
  (club-level init-form: (randval 8))
  ((show)
   (str "A wicked orc with a level " club-level " club"))
  ((attack)
   (let ((x (randval club-level)))
     (output "An orc swings his club at you for " x " health!")
     (swap! *player-health* - x))))
(swap! *monster-builders* conj orc)

;; The Malicious Hydra
(define-class hydra (monster)
  ((show)
   (str "A malicious hydra with " (this):health " heads"))
  ((hit x)
   (swap! (this):health - x)
   (if (monster-dead? (this))
       (output "The fully decapitated hydra falls to the floor!")
       (output "You lop off " x " of the hydra's heads!")))
  ((attack)
   (let ((x (randval (quotient (this):health 2))))
     (output "A hydra attacks you with " x " of its heads!")
     (swap! *player-health* - x)
     (output "It also grows back 1 more head!")
     (swap! (this):health inc))))
(swap! *monster-builders* conj hydra)

;; The Slimey Slime Mold
(define-class slime (monster)
  (sliminess init-form: (randval 5))
  ((show)
   (str "A slime with a sliminess of " sliminess))
  ((attack)
   (let ((x (randval sliminess)))
     (output "A slime wraps around your legs for " x " agility!")
     (swap! *player-agility* - x)
     (when (zero? (rand-int 2))
       (output "It also squirts in your face for 1 health!")
       (swap! *player-health* dec)))))
(swap! *monster-builders* conj slime)

;; The Cunning Brigand
(define-class brigand (monster)
  ((attack)
   (let ((x (max *player-health* *player-agility* *player-strength*)))
     (cond ((= x *player-health*)
            (output "A brigand hits with his slingshot for 2 health!")
            (swap! *player-health* - 2))
           ((= x *player-agility*)
            (output "A brigand whips your leg for 2 agility!")
            (swap! *player-agility* - 2))
           ((= x *player-strength*)
            (output "A brigand whips your arm for 2 strength!")
            (swap! *player-strength* - 2))))))
(swap! *monster-builders* conj brigand)
