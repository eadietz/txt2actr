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
(chunk-type goal state next) 
(chunk-type display-info name screenx screeny) 
(chunk-type button-info name screenx screeny) 
(chunk-type image-info name screenx screeny) 
(chunk-type sound-info name) 
(chunk-type sa-level val) 
(chunk-type SA event aoi eeg action1 action2 action3 time) 
(chunk-type list-info current-on-list next-on-list) 


(define-chunks ;; define the chunk for each item (label) 
(item) 
)

(add-dm ;; the location specification for each item (label) value 
 (item-info isa display-info name item screenx 467 screeny 368) 
;; the list of items that are to be attended in a routine loop 
(item-0 ISA list-info current-on-list item next-on-list item) 
 

)(p scan-if-scene-changed
     ?visual-location>
       state     free
     ?visual>
       state     free
       scene-change  t
   ==>
     +visual-location>
       :attended new
 )
 
  (p attend-item-if-loc-scanned
      =visual-location>
        isa       visual-location
        screen-x  =screenx
        screen-y  =screeny
      ?visual>
        state     free
      ?retrieval>
        state     free
    ==>
      ;; length of value in pixels (1 character is 7 pixels)
      !bind! =maxx (+ =screenx 35)
      !bind! =minx (- =screenx 35)
      ;; height of word in pixels (e.g. fontsize 12 is 16px)
      !bind! =maxy (+ =screeny 16)
      !bind! =miny (- =screeny 16)
      +visual>
        cmd           move-attention
        screen-pos    =visual-location
      +retrieval>
        <= screenx =maxx
        >= screenx =minx
        <= screeny  =maxy
        >= screeny  =miny
  )
 
  (p update-if-item-retrieved
      =retrieval>
        name      =name
      ?imaginal>
       state     free
      ?visual-location>
        state     free
      =visual>
        value     =val
    ==>
      +imaginal>
        =name     =val
    !output! (DDR +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Retrieval
    successful. Display =name is updated with =val)
  )
 
 ;(spp attend-item-if-loc-scanned :u 10)
 ;(spp update-if-item-retrieved :u 13)


 (chunk-type goal state)
 (chunk-type pair probe answer)
 
 (add-dm
  (start isa chunk) (attending-target isa chunk)
  (attending-probe isa chunk)
  (testing isa chunk) (read-study-item isa chunk)
 
  (goal isa goal state start))
 
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
    ==>
     !output! (probe =val)
     +imaginal>
       isa      pair
       probe    =val
     +retrieval>
       isa      pair
       probe    =val
     =goal>
       state    testing
 )
 
 (p recall
     =goal>
       isa      goal
       state    testing
     =retrieval>
       isa      pair
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
    =imaginal>
       isa      pair
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
 
 
 (goal-focus goal)




)