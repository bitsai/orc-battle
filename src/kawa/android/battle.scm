(require 'android-defs)

(define *display* ::android.widget.TextView #!null)
(define *scroller* ::android.widget.ScrollView #!null)

(activity
 battle
 (on-create
  ((this):setContentView kawa.android.R$layout:main)
  (set! *display* (as <android.widget.TextView>
		      ((this):findViewById kawa.android.R$id:display)))
  (set! *scroller* (as <android.widget.ScrollView>
		       ((this):findViewById kawa.android.R$id:scroller))))
 ((onEnter (v ::android.view.View)) ::void
  (let ((input (as <android.widget.EditText>
		   ((this):findViewById kawa.android.R$id:input))))
  (process input:text))))

(define (show text ::string) ::void
  (*display*:append text)
  (*scroller*:post
   (lambda () (*scroller*:fullScroll android.widget.ScrollView:FOCUS_DOWN))))

(define (process text ::string) ::void
  (show (string-append text "\n")))
