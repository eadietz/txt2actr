(clear-all)
(define-model flight-task
 (sgp
   ;:act nil
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
   ;:rt -0.5
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
(APU_FIRE_WARNINGMASTER_WARNING) 
(BARO_1_CORRECT_ALTITUDE_LSP) 
(SELECTED_VERTICAL_SPEED) 
(button_1) 
(button_2) 
(button_3) 
(button_4) 
(ALTITUDE) 
(PTCH) 
(ROLL) 
(SPEED) 
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
 (APU_FIRE_WARNINGMASTER_WARNING-info isa display-info name APU_FIRE_WARNINGMASTER_WARNING screen-x 517.0 screen-y 324.0) 
 (BARO_1_CORRECT_ALTITUDE_LSP-info isa display-info name BARO_1_CORRECT_ALTITUDE_LSP screen-x 517.0 screen-y 300.0) 
 (SELECTED_VERTICAL_SPEED-info isa display-info name SELECTED_VERTICAL_SPEED screen-x 517.0 screen-y 276.0) 
 (button_1-info isa button-info name button_1 screen-x 930.0 screen-y 245.0) 
 (button_2-info isa button-info name button_2 screen-x 880.0 screen-y 295.0) 
 (button_3-info isa button-info name button_3 screen-x 980.0 screen-y 295.0) 
 (button_4-info isa button-info name button_4 screen-x 930.0 screen-y 345.0) 
 (ALTITUDE-info isa display-info name ALTITUDE screen-x 317.0 screen-y 694.0) 
 (PTCH-info isa display-info name PTCH screen-x 317.0 screen-y 670.0) 
 (ROLL-info isa display-info name ROLL screen-x 317.0 screen-y 646.0) 
 (SPEED-info isa display-info name SPEED screen-x 317.0 screen-y 622.0) 
 (MASTER_WARNING-info isa display-info name MASTER_WARNING screen-x 1282.0 screen-y 514.0) 
 (SMOK-info isa display-info name SMOK screen-x 1282.0 screen-y 490.0) 
 (TAKEOFF_CONF_WARNING-info isa display-info name TAKEOFF_CONF_WARNING screen-x 1282.0 screen-y 466.0) 
 (WIND-FLAP_POSITION-info isa display-info name WIND-FLAP_POSITION screen-x 1282.0 screen-y 442.0) 
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
;; the list of items that are to be attended in a routine loop 
(CASS-0 ISA list-info current-on-list CASS next-on-list CASS) 
 
)


 
 (set-buffer-chunk 'retrieval 'CASS-info)
 
 (p retrieve-item-from-list
       =goal>
         state    idle
       ?retrieval>
         state     free
      ==>
       +retrieval>
         - current-on-list    nil
       =goal>
   )
 
   (p scan-if-item-retrieved
        =goal>
         state    idle
        =retrieval>
          current-on-list       =name
        ?visual-location>
          state     free
        ?visual>
          state     free
        ?imaginal>
          state    free
      ==>
       +visual-location>
          color =name
      +visual>
          clear     t ;; Stop visual buffer from updating without explicit requests
       =retrieval>
      =goal>
        state    attend
       +imaginal>
          =name  nil
      )
 
  (p attend
      =goal>
        state    attend
      =visual-location>
      ?visual>
         state   free
      ==>
      =visual-location>
      +visual>
        cmd       move-attention
        screen-pos =visual-location
      =goal>
        state    read
    )
 
    (p read-info
       =goal>
         state     read
       =retrieval>
        current-on-list  =current
        next-on-list  =next
        =visual>
          value     =val
      =imaginal>
      ==>
      =imaginal>
          =current =val
      +retrieval>
        current-on-list  =next
      =goal>
        state    idle
        !output! (goal-driven update +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Retrieved and attended
        successfully. Display =current is updated with =val)
         !eval! ("pass_data_to_sim" (list =val))
    )




 )