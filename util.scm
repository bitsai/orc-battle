(define (output . xs)
  (display (apply str xs)))

(define (rand-int n)
  (*:nextInt (java.util.Random) n))

(define (rand-nth lst)
  (list-ref lst (rand-int (length lst))))

(define-syntax dolist
  (syntax-rules ()
    ((dolist (counter init) body ...)
     (for-each (lambda (counter)
		 body ...)
	       init))
    ((dolist (counter ::type init) body ...)
     (for-each (lambda (counter ::type)
		 body ...)
	       init))))

(define-syntax dotimes
  (syntax-rules ()
    ((dotimes (counter init) body ...)
     (do ((max init)
	  (counter 0 (inc counter)))
	 ((= counter max))
       body ...))))

(define (inc n)
  (+ n 1))

(define (dec n)
  (- n 1))

(define (nil? x)
  (eqv? #!null x))

(define (type-of obj)
  (*:getName (*:getClass obj)))

(define (str . xs)
  (let ((o (open-output-string)))
    (dolist (x xs)
	    (display x o))
    (get-output-string o)))
