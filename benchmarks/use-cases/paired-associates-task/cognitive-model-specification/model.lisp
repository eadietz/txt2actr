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
(add-word-characters "_")
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
(chunk-type collector name probe associate) 


(define-chunks ;; define the chunk for each item (label) 
(probe_associate) 
)

(add-dm (goal isa goal state set-default-val)) 
 (goal-focus goal) 


(add-dm ;; the location specification for each item (label) value 
 (probe_associate-info isa display-info name probe_associate screen-x 467 screen-y 368) 
;; the list of items that are to be attended in a routine loop 
(probe_associate-0 ISA list-info current-on-list probe_associate next-on-list probe_associate) 
 
)

(p set-default-values ;; start model, set imaginal chunk
    =goal>
      state     set-default-val
    ?imaginal>
      state    free
      buffer   empty
   ==>
    +imaginal>
      isa collector
	  name 	 nil 
	  probe 	 nil 
	  associate 	 nil 
	=goal>
      state    start
)


(set-buffer-chunk 'retrieval 'probe_associate-info) 
; (sgp :scene-change-threshold 1.0)
 
 (p scan-if-scene-changed
     =goal>
       isa      goal
       state    start
     ?imaginal>
       state    free
     =visual-location>
     ?visual>
       scene-change t
       state        free
   ==>
     +visual-location>
       :attended new
     +imaginal>
       isa collector
       name       nil
     =goal>
       state    update
 )
 
  (p attend-retrieve-if-location-scanned
     =goal>
       isa      goal
       state    update
      ?retrieval>
         state     free
      =visual-location>
        isa       visual-location
        screen-x  =screenx
        screen-y  =screeny
        ;color     =name
     ?visual>
       state     free
    ==>
      ;; length of value in pixels (1 character is 7 pixels), the margin needs to be adapted according to the environment
      !bind! =maxx (+ =screenx 20)
      !bind! =minx (- =screenx 20)
      ; height of word in pixels (e.g. fontsize 12 is 16px)
      !bind! =maxy (+ =screeny 16)
      !bind! =miny (- =screeny 16)
      +visual>
        cmd           move-attention
        screen-pos    =visual-location
      +retrieval>
        isa display-info
        <= screen-x =maxx
        >= screen-x =minx
        <= screen-y =maxy
        >= screen-y =miny
     =goal>
     =visual-location
     ;@visual-location>
  )
 
  (p dd-visual-ip-update-if-item-retrieved
     =goal>
       isa      goal
       state    update
      =visual>
        value     =val
      =retrieval>
        name      =name
     ?imaginal>
       state    free
    =imaginal>
       ;isa collector
       ;name      =name
     ?visual>
       state    free
    ==>
       @imaginal>
         isa collector
         =name  =val
      +imaginal>
       isa collector
       name       nil
     =goal>
       state    start
     +visual>
       cmd      clear
       !output! (data-driven update +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Attended and retrieved
       successfully. Display =name is updated with =val)
  )
 
 (p handle-find-loc-failure
      ?visual-location>
        state     error
       ?visual>
         state     free
     =imaginal>
         state    free
     ==>
     +visual>
         clear     t
  )
 
 ; specify production rule priorities for DDAR
 ;(spp scan-if-scene-changed :u 0.1)
 ;(spp attend-retrieve-if-location-scanned :u 1)
 ;(spp dd-visual-ip-update-if-item-retrieved :u 5)



 (sgp :seed (200 4))
 
 ;(add-dm
 ; (start isa chunk) (attending-target isa chunk)
 ; (attending-probe isa chunk)
 ; (testing isa chunk) (read-study-item isa chunk)
 ; )
 
 (p attend-probe
     =goal>
       isa      goal
       state    start
     ?imaginal>
       state    free
     =visual-location>
     ?visual>
       scene-change t
       state        free
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
       value    =val
     ?imaginal>
       state    free
     ?retrieval>
       state    free
    ==>
     +imaginal>
       isa      collector
       probe    =val
     +retrieval>
       isa      collector
       probe    =val
     =goal>
       state    testing
 )
 
 (p recall
     =goal>
       isa      goal
       state    testing
     =retrieval>
       isa      collector
       answer   =ans
     ?manual>
       state    free
     ?visual>
       state    free
    ==>
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
       value    =val
    =imaginal>
       isa      collector
       probe    =probe
     ?visual>
       state    free
   ==>
    =imaginal>
       answer   =val
    -imaginal>
    =goal>
       state    start
    +visual>
       cmd      clear
 )
 
 
 ; (goal-focus goal)
 
 ;(spp attend-probe :u 0.1)
 ;(spp read-probe :u 0)
 ;(spp recall :u 0)
 ;(spp detect-study-item :u 0)




)