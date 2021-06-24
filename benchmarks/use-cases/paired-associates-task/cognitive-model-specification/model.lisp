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
   :esc t
   :egs 0.95 ; noise in utility based  choosing production rules
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
 (probe_associate-info isa display-info name probe_associate screen-x 593 screen-y 368) 
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
      state    idle
)


(set-buffer-chunk 'retrieval 'probe_associate-info) 

  (p scan-if-item-retrieved
       =goal>
        state    idle
       =imaginal>
        name       nil
     ?imaginal>
       state    free
       =retrieval>
         name       =name
         screen-x     =screenx
         screen-y     =screeny
       =visual-location>
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
     =goal>
       state    gd-attend
   )
 
 (p retrieve-attend-if-location-scanned
     =goal>
       state    gd-attend
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
     =goal>
       state    gd-update
   )
 
   (p gd-visual-ip-update-if-next-retrieved
     =goal>
       state    gd-update
      =retrieval>
       current-on-list  =current
       next-on-list  =next
       =imaginal>
       =visual>
         value     =val
     ==>
       =imaginal>
         =current  =val
         name  nil
       +retrieval>
         name  =next
     =goal>
       state    idle
       !output! (goal-driven update +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Retrieved and attended
       successfully. Display =current is updated with =val)
   )
 
 ; specify production rule priorities for goal driven component
 (spp scan-if-item-retrieved :u 1)
 
 
 ; get back to list, when loop was interrupted
 (p retrieve-again-item-from-list
      =goal>
        state  idle
      ?retrieval>
        buffer    empty
     ==>
      +retrieval>
        - next-on-list    nil
      =goal>
  )
 
 ; catch failures, not necessary



 (sgp :seed (200 4))
 
 ;(add-dm
 ; (start isa chunk) (attending-target isa chunk)
 ; (attending-probe isa chunk)
 ; (testing isa chunk) (read-study-item isa chunk)
 ; )
 
 (p attend-probe
     =goal>
       state    idle
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
       state    idle
    +visual>
       cmd      clear
 )
 
 
 ; (goal-focus goal)
 
 (spp attend-probe :u 1.5)
 ;(spp read-probe :u 0)
 ;(spp recall :u 0)
 ;(spp detect-study-item :u 0)




)