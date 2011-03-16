(require 'android-defs)

(define *display* ::android.widget.TextView #!null)
(define *scroller* ::android.widget.ScrollView #!null)
(define *input* ::android.widget.EditText #!null)

(activity
 battle
 (on-create
  ((this):setContentView kawa.android.R$layout:main)
  (set! *display* (as <android.widget.TextView>
		      ((this):findViewById kawa.android.R$id:display)))
  (set! *scroller* (as <android.widget.ScrollView>
		       ((this):findViewById kawa.android.R$id:scroller)))
  (set! *input* (as <android.widget.EditText>
		    ((this):findViewById kawa.android.R$id:input)))
  (new-game)))

(define (onEnter (v ::android.view.View)) ::void
  (show (string-append *input*:text "\n")))

(define (show text ::string) ::void
  (*display*:append text)
  (*scroller*:post
   (lambda ()
     (*scroller*:fullScroll android.widget.ScrollView:FOCUS_DOWN))))

(define (new-game)
  (show "You are a mystic monk.\n"))
