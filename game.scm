(require "engine.scm")
(require "util.scm")

(define (output . xs)
  (display (apply str xs)))

(new-game)
