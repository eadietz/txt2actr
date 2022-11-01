(clear-all)
(define-model flight-task
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
   :v nil
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
(PTCH) 
(ROLL) 
(Autopilot) 
(MASTER_WARNING) 
(SMOK) 
(TAKEOFF_CONF_WARNING) 
(WIND-FLAP_POSITION) 
(GEARS_L-R_DOWN_LOCKED) 
(GEARS_L-R_UP_LOCKED) 
(M) 
(Y) 
(SEC) 
(MIN) 
(HRS) 
(POWER_LEVER_ANGLE_1) 
(POWER_LEVER_ANGLE_2) 
(POWER_LEVER_ANGLE_3) 
(POWER_LEVER_ANGLE_4) 
(A_LOT_OF_BUTTONS) 
(APUF) 
(MW) 
(TOCW) 
(WSHR) 
)

(add-dm (starting-goal isa goal state idle)) 
 (goal-focus starting-goal) 


(add-dm ;; the location specification for each item (label) value 
 (button_1-info isa button-info name button_1 screen-x 930.0 screen-y 245.0) 
 (button_2-info isa button-info name button_2 screen-x 880.0 screen-y 295.0) 
 (button_3-info isa button-info name button_3 screen-x 980.0 screen-y 295.0) 
 (button_4-info isa button-info name button_4 screen-x 930.0 screen-y 345.0) 
 (PTCH-info isa display-info name PTCH screen-x 317.0 screen-y 694.0) 
 (ROLL-info isa display-info name ROLL screen-x 317.0 screen-y 670.0) 
 (Autopilot-info isa display-info name Autopilot screen-x 1282.0 screen-y 514.0) 
 (MASTER_WARNING-info isa display-info name MASTER_WARNING screen-x 1282.0 screen-y 490.0) 
 (SMOK-info isa display-info name SMOK screen-x 1282.0 screen-y 466.0) 
 (TAKEOFF_CONF_WARNING-info isa display-info name TAKEOFF_CONF_WARNING screen-x 1282.0 screen-y 442.0) 
 (WIND-FLAP_POSITION-info isa display-info name WIND-FLAP_POSITION screen-x 1282.0 screen-y 418.0) 
 (GEARS_L-R_DOWN_LOCKED-info isa display-info name GEARS_L-R_DOWN_LOCKED screen-x 1537.0 screen-y 514.0) 
 (GEARS_L-R_UP_LOCKED-info isa display-info name GEARS_L-R_UP_LOCKED screen-x 1537.0 screen-y 490.0) 
 (M-info isa display-info name M screen-x 862.0 screen-y 709.0) 
 (Y-info isa display-info name Y screen-x 862.0 screen-y 685.0) 
 (SEC-info isa display-info name SEC screen-x 862.0 screen-y 661.0) 
 (MIN-info isa display-info name MIN screen-x 862.0 screen-y 637.0) 
 (HRS-info isa display-info name HRS screen-x 862.0 screen-y 613.0) 
 (POWER_LEVER_ANGLE_1-info isa display-info name POWER_LEVER_ANGLE_1 screen-x 862.0 screen-y 904.0) 
 (POWER_LEVER_ANGLE_2-info isa display-info name POWER_LEVER_ANGLE_2 screen-x 862.0 screen-y 880.0) 
 (POWER_LEVER_ANGLE_3-info isa display-info name POWER_LEVER_ANGLE_3 screen-x 862.0 screen-y 856.0) 
 (POWER_LEVER_ANGLE_4-info isa display-info name POWER_LEVER_ANGLE_4 screen-x 862.0 screen-y 832.0) 
 (A_LOT_OF_BUTTONS-info isa display-info name A_LOT_OF_BUTTONS screen-x 517.0 screen-y 133.0) 
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