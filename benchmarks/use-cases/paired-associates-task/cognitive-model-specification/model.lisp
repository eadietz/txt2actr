(clear-all)
(define-model paired-associates-task
 (sgp
   ;:act nil
   ;:ncnar nil
   ;:aural-activation 10
   ;:visual-activation 10
   ;:imaginal-activation 10
   ;:retrieval-activation 10
   :auto-attend t ;; -auto-attend 
   ;:bll 0.5
   ;:declarative-finst-span 1.0
   ;:emt nil ; em? et? em?
   ;:esc t
   ;:mas 5 ;1.6
   ;:mp 1.0
   ;:retrieval-activation 10
   ;:rt -2
   :show-focus t
   ;:sound-decay-time 1
   ;:time-master-start-increment 1.0
   ;:time-mult 1
   ;:time-noise 0.001
   :trace-detail low
   ;:ul t
   ;:unstuff-aural-location t
   :v t ;; -model-output 
   ;:visual-activation 10
   ;:tone-detect-delay 1.0
   ;:lf 0.4
   ;:ans 0.5
   )

(sgp :seed (200 4))


(add-word-characters ".")
(set-visloc-default)

;; ---> insert additional model modules after here


;; Define the chunk types for the chunks 
(chunk-type goal state) 
(chunk-type display-info name screen-x screen-y) 
(chunk-type button-info name screen-x screen-y) 
(chunk-type image-info name screen-x screen-y) 
(chunk-type sound-info name) 
(chunk-type sa-level val) 
(chunk-type SA event aoi eeg action1 action2 action3 time) 
(chunk-type list-info current-on-list next-on-list) 


(define-chunks ;; define the chunk for each item (label) 
(item) 
)

(add-dm (goal isa goal state set-default-val)) 
 (goal-focus goal) 


(add-dm ;; the location specification for each item (label) value 
 (item-info isa display-info name item screen-x 467 screen-y 368) 
;; the list of items that are to be attended in a routine loop 
(item-0 ISA list-info current-on-list item next-on-list item) 
 
)

(p set-default-values ;; start model, set imaginal chunk
    =goal>
      state     set-default-val
    ?imaginal>
      buffer    empty
   ==>
    +imaginal>
	  probe 	 nil 
	  answer 	 nil 
	  name 	 nil 
	=goal>
      state    start
)


(set-buffer-chunk 'retrieval 'item-info) 
  (p scan-if-item-retrieved
       =imaginal>
        name       nil
     ?imaginal>
       state    free
       =retrieval>
         name       =name
         screen-x     =screenx
         screen-y     =screeny
       ?visual-location>
         state     free
       ?visual>
         state     free
     ==>
      !bind! =maxx (+ =screenx 15)
      !bind! =minx (- =screenx 15)
      +visual-location>
         <= screen-x   =maxx
         >= screen-x   =minx
         screen-y   =screeny
     +visual>
         clear     t ;; Stop visual buffer from updating without explicit requests
      =retrieval>
     =imaginal>
        name       =name
   )
 
 (p retrieve-attend-if-location-scanned
      ?retrieval>
         state     free
      =retrieval>
        name        =current
         screen-x     =screenx
         screen-y     =screeny
      !bind! =maxx (+ =screenx 15)
      !bind! =minx (- =screenx 15)
      =visual-location>
         <= screen-x   =maxx
         >= screen-x   =minx
         screen-y   =screeny
     ?visual>
        state   free
     ==>
     +visual>
       cmd       move-attention
       screen-pos =visual-location
     +retrieval>
       current-on-list  =current
   )
 
   (p gd-visual-ip-update-if-next-retrieved
      ?retrieval>
         state     free
      =retrieval>
       current-on-list  =current
       next-on-list  =next
       =imaginal>
      ?imaginal>
         state     free
       =visual>
         value     =val
     ==>
       =imaginal>
         =current  =val
         name  nil
       +retrieval>
         name  =next
       !output! (goal-driven update +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Retrieved and attended
       successfully. Display =current is updated with =val)
   )
 
 
 ; these production rules might not be necessary
 #|(p scan-again-if-retrieval-failed
      ?visual-location>
        state     error
       ?visual>
         state     free
     ==>
      +visual>
         clear     t ;; Stop visual buffer from updating without explicit requests
  )
 
 (p retrieve-again-if-retrieval-failed
      ?retrieval>
         state     error
     ==>
      +retrieval>
        - next-on-list    nil
      +visual>
         clear     t ;; Stop visual buffer from updating without explicit requests
 
  )|#
 
 ; specify production rule priorities for GDRA
 ;(spp scan-if-retrieved :u 10)
 ;(spp retrieve-attend-if-scanned :u 10)
 ;(spp gdra-update-if-retrieved :u 10)


 (chunk-type pair probe answer)
 
 (add-dm
  (start isa chunk) (attending-target isa chunk)
  (attending-probe isa chunk)
  (testing isa chunk) (read-study-item isa chunk)
  )
 
 
 (p attend-probe
     =goal>
       isa      goal
       state    start
     =visual-location>
     ?visual>
      state     free
    ==>
     +visual>
       cmd      move-attention
       screen-pos =visual-location
     =goal>
       state    attending-probe
 )
 
 (p read-probe
     =goal>
       isa      goal
       state    attending-probe
     =visual>
       isa      visual-object
       value    =val
     ?imaginal>
       state    free
     =imaginal>
    ==>
     !output! (probe =val)
     +imaginal>
       probe    =val
     +retrieval>
       probe    =val
     =goal>
       state    testing
 )
 
 (p recall
     =goal>
       isa      goal
       state    testing
     =retrieval>
       answer   =ans
     ?manual>
       state    free
     ?visual>
       state    free
    ==>
     !output! (answer =ans)
     +manual>
       cmd      press-key
       key      =ans
     =goal>
       state    read-study-item
     +visual>
       cmd      clear
 )
 
 
 (p cannot-recall
     =goal>
       isa      goal
       state    testing
     ?retrieval>
       buffer   failure
     ?visual>
       state    free
    ==>
     =goal>
      state    read-study-item
     +visual>
      cmd      clear
 )
 
 (p detect-study-item
     =goal>
       isa      goal
       state    read-study-item
     =visual-location>
     ?visual>
       state    free
    ==>
     +visual>
       cmd      move-attention
       screen-pos =visual-location
     =goal>
       state    attending-target
 )
 
 
 (p associate
     =goal>
       isa      goal
       state    attending-target
     =visual>
       isa      visual-object
       value    =val
     ?imaginal>
       state    free
    =imaginal>
       probe    =probe
     ?visual>
       state    free
   ==>
    +imaginal>
       answer   =val
    =goal>
       state    start
    +visual>
       cmd      clear
 )
 
 
 (goal-focus goal)




)