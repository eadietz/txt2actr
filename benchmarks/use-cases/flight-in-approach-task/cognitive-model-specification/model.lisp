(clear-all)
(define-model flight-task-in-spptosvh
 (sgp
   ;:act nil
   ;:aural-activation 10
   ;:visual-activation 10
   ;:imaginal-activation 10
   ;:retrieval-activation 10
   ;:auto-attend t ;; -auto-attend
   ;:bll 0.5
   ;:declarative-finst-span 1.0
   ;:emt nil ; em? et? em?
   ;:esc t
   ;:mas 5 ;1.6
   ;:mp 1.0
   ;:retrieval-activation 10
   ;:rt -0.5
   :show-focus t
   ;:sound-decay-time 1
   ;:time-master-start-increment 1.0
   ;:time-mult 1
   ;:time-noise 0.001
   :trace-detail low
   :ul t
   ;:unstuff-aural-location t
   :v t
;; -model-output
   ;:visual-activation 10
   ;:tone-detect-delay 1.0
   )


 (add-word-characters ".")
 (add-word-characters ",")
 (add-word-characters "_")
 (add-word-characters "/")
 (add-word-characters "-")
(add-word-characters "  :")
(add-word-characters ":  ")

(set-visloc-default)

; an experienced pilot knows everything very well
(set-all-base-levels 100000 -1000)
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
(button_1) 
(button_2) 
(button_3) 
(button_4) 
(time) 
)

(add-dm (starting-goal isa goal state idle)) 
 (goal-focus starting-goal) 


(add-dm ;; the location specification for each item (label) value 
 (button_1-info isa button-info name button_1 screen-x 930.0 screen-y 245.0) 
 (button_2-info isa button-info name button_2 screen-x 880.0 screen-y 295.0) 
 (button_3-info isa button-info name button_3 screen-x 980.0 screen-y 295.0) 
 (button_4-info isa button-info name button_4 screen-x 930.0 screen-y 345.0) 
 (time-info isa display-info name time screen-x 338.0 screen-y 694.0) 
)

#|(p scan-if-scene-did-not-change
     =goal>
       state    idle
   ==>
     =goal>
       state    wait
 )
 
 (p wait
     =goal>
       state    wait
   ==>
     =goal>
       state    idle
       !eval! ("waiting")
 )|#
 
 (p scan-if-scene-changed
     =goal>
       state    idle
     ?imaginal>
       state    free
     ?visual-location>
       state    free
     ?visual>
       scene-change t
       state        free
   ==>
     +visual-location>
       :attended nil
     +imaginal>
       name       nil
     =goal>
       state    dd-attend
 )
 
 
 ; specify production rule priorities for data driven component
 ;(spp scan-if-scene-changed :u 100)
 ;(spp scan-if-scene-did-not-change :u 1)
 
  (p attend-retrieve-if-location-scanned
     =goal>
       state    dd-attend
      ?retrieval>
         state     free
      =visual-location>
        isa       visual-location
        color     =name
     ?visual>
        state     free
    ==>
      +visual>
        cmd           move-attention
        screen-pos    =visual-location
      +retrieval>
        isa display-info
        name     =name
     =goal>
       state    dd-update
  )
 
  (p dd-visual-ip-update-if-item-retrieved
     =goal>
       state     dd-update
      =visual>
        value     =val
      =retrieval>
        name      =current
      =imaginal>
     ?visual>
       state    free
    ==>
       !bind! =number (read-from-string =val)
      +imaginal>
         =current  =number
         name  nil
     +visual>
         cmd    clear
     =goal>
       state    idle
       !eval! ("print_read_data" (list =current =number))
       ;!output! (data-driven update +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Attended and retrieved
       ;successfully. Display =current is updated with =val)
  )
 
 
  (p change-if-altitude
     =goal>
       state     idle
     =imaginal>
        > ALTITUDE 100
        ALTITUDE =val
     ?visual>
       state    free
    ==>
     -imaginal>
     =goal>
       state    idle
     !eval! ("pass_data_to_sim" (list "ALTITUDE" =val))
 )
 
 ; specify production rule priorities
 (spp change-if-altitude :u 100)
 (spp scan-if-scene-changed :u 1)
 
 ;; catch failures, not necessary
 (p handle-retrieval-failure
    =goal>
       state dd-update
     ?retrieval>
        state     error
     =visual-location>
     ==>
     +visual-location>
       :attended new
    =goal>
       state dd-attend
 )



 )