(define (conj lst x)
  (cons x lst))

(define-syntax dolist
  (syntax-rules ()
    ((dolist (x lst) body ...)
     (for-each (lambda (x)
		 body ...)
	       lst))
    ((dolist (x ::type lst) body ...)
     (for-each (lambda (x ::type)
		 body ...)
	       lst))))

(define-syntax dotimes
  (syntax-rules ()
    ((dotimes (x init) body ...)
     (do ((max init)
	  (x 0 (inc x)))
	 ((= x max))
       body ...))))

(define (dec n)
  (- n 1))

(define (inc n)
  (+ n 1))

(define *rand* (java.util.Random))

(define (rand-int n)
  (*rand*:nextInt n))

(define (rand-nth lst)
  (list-ref lst (rand-int (length lst))))

(define (read-string s)
  (read (open-input-string s)))

(define (str . xs)
  (let ((o (open-output-string)))
    (for-each (lambda (x) (display x o)) xs)
    (get-output-string o)))

(define-syntax swap!
  (syntax-rules ()
    ((swap! x f args ...)
     (set! x (f x args ...)))))
