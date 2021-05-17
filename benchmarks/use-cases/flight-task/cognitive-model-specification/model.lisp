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
(SELECTED_ALTITUDE_LSP) 
(BARO_1_CORRECT_ALTITUDE_LSP) 
(SELECTED_VERTICAL_SPEED) 
(button_1) 
(button_2) 
(button_3) 
(button_4) 
(ALTITUDE) 
(SPEED) 
(APU_FIRE_WARNINGMASTER_WARNING) 
(MASTER_WARNING) 
(SMOK) 
(TAKEOFF_CONF_WARNING) 
(WIND-FLAP_POSITION) 
(GEARS_L-R_DOWN_LOCKED) 
(GEARS_L-R_UP_LOCKED) 
(D) 
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

(add-dm (goal isa goal state set-default-val)) 
 (goal-focus goal) 


(add-dm ;; the location specification for each item (label) value 
 (SELECTED_ALTITUDE_LSP-info isa display-info name SELECTED_ALTITUDE_LSP screen-x 567 screen-y 324) 
 (BARO_1_CORRECT_ALTITUDE_LSP-info isa display-info name BARO_1_CORRECT_ALTITUDE_LSP screen-x 567 screen-y 300) 
 (SELECTED_VERTICAL_SPEED-info isa display-info name SELECTED_VERTICAL_SPEED screen-x 567 screen-y 276) 
 (button_1-info isa button-info name button_1 screen-x 930 screen-y 245) 
 (button_2-info isa button-info name button_2 screen-x 880 screen-y 295) 
 (button_3-info isa button-info name button_3 screen-x 980 screen-y 295) 
 (button_4-info isa button-info name button_4 screen-x 930 screen-y 345) 
 (ALTITUDE-info isa display-info name ALTITUDE screen-x 312 screen-y 514) 
 (SPEED-info isa display-info name SPEED screen-x 312 screen-y 490) 
 (APU_FIRE_WARNINGMASTER_WARNING-info isa display-info name APU_FIRE_WARNINGMASTER_WARNING screen-x 1332 screen-y 514) 
 (MASTER_WARNING-info isa display-info name MASTER_WARNING screen-x 1332 screen-y 490) 
 (SMOK-info isa display-info name SMOK screen-x 1332 screen-y 466) 
 (TAKEOFF_CONF_WARNING-info isa display-info name TAKEOFF_CONF_WARNING screen-x 1332 screen-y 442) 
 (WIND-FLAP_POSITION-info isa display-info name WIND-FLAP_POSITION screen-x 1332 screen-y 418) 
 (GEARS_L-R_DOWN_LOCKED-info isa display-info name GEARS_L-R_DOWN_LOCKED screen-x 1587 screen-y 514) 
 (GEARS_L-R_UP_LOCKED-info isa display-info name GEARS_L-R_UP_LOCKED screen-x 1587 screen-y 490) 
 (D-info isa display-info name D screen-x 912 screen-y 709) 
 (M-info isa display-info name M screen-x 912 screen-y 685) 
 (Y-info isa display-info name Y screen-x 912 screen-y 661) 
 (SEC-info isa display-info name SEC screen-x 912 screen-y 637) 
 (MIN-info isa display-info name MIN screen-x 912 screen-y 613) 
 (HRS-info isa display-info name HRS screen-x 912 screen-y 589) 
 (POWER_LEVER_ANGLE_1-info isa display-info name POWER_LEVER_ANGLE_1 screen-x 912 screen-y 904) 
 (POWER_LEVER_ANGLE_2-info isa display-info name POWER_LEVER_ANGLE_2 screen-x 912 screen-y 880) 
 (POWER_LEVER_ANGLE_3-info isa display-info name POWER_LEVER_ANGLE_3 screen-x 912 screen-y 856) 
 (POWER_LEVER_ANGLE_4-info isa display-info name POWER_LEVER_ANGLE_4 screen-x 912 screen-y 832) 
 (A_LOT_OF_BUTTONS-info isa display-info name A_LOT_OF_BUTTONS screen-x 567 screen-y 133) 
;; the list of items that are to be attended in a routine loop 
(ALTITUDE-0 ISA list-info current-on-list ALTITUDE next-on-list SPEED) 
 (SPEED-1 ISA list-info current-on-list SPEED next-on-list ALTITUDE) 
 
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
	  speed 	 0 
	  altitude 	 0 
	  name 	 nil 
	=goal>
      state    start
)


(set-buffer-chunk 'retrieval 'ALTITUDE-info) 
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



)