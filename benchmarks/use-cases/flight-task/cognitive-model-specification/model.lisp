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
(chunk-type goal state next) 
(chunk-type display-info name screenx screeny) 
(chunk-type button-info name screenx screeny) 
(chunk-type image-info name screenx screeny) 
(chunk-type sound-info name) 
(chunk-type sa-level val) 
(chunk-type SA event aoi eeg action1 action2 action3 time) 
(chunk-type list-info current-on-list next-on-list) 


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
 (SELECTED_ALTITUDE_LSP-info isa display-info name SELECTED_ALTITUDE_LSP screenx 567 screeny 324) 
 (BARO_1_CORRECT_ALTITUDE_LSP-info isa display-info name BARO_1_CORRECT_ALTITUDE_LSP screenx 567 screeny 300) 
 (SELECTED_VERTICAL_SPEED-info isa display-info name SELECTED_VERTICAL_SPEED screenx 567 screeny 276) 
 (button_1-info isa button-info name button_1 screenx 930 screeny 245) 
 (button_2-info isa button-info name button_2 screenx 880 screeny 295) 
 (button_3-info isa button-info name button_3 screenx 980 screeny 295) 
 (button_4-info isa button-info name button_4 screenx 930 screeny 345) 
 (ALTITUDE-info isa display-info name ALTITUDE screenx 312 screeny 514) 
 (SPEED-info isa display-info name SPEED screenx 312 screeny 490) 
 (APU_FIRE_WARNINGMASTER_WARNING-info isa display-info name APU_FIRE_WARNINGMASTER_WARNING screenx 1332 screeny 514) 
 (MASTER_WARNING-info isa display-info name MASTER_WARNING screenx 1332 screeny 490) 
 (SMOK-info isa display-info name SMOK screenx 1332 screeny 466) 
 (TAKEOFF_CONF_WARNING-info isa display-info name TAKEOFF_CONF_WARNING screenx 1332 screeny 442) 
 (WIND-FLAP_POSITION-info isa display-info name WIND-FLAP_POSITION screenx 1332 screeny 418) 
 (GEARS_L-R_DOWN_LOCKED-info isa display-info name GEARS_L-R_DOWN_LOCKED screenx 1587 screeny 514) 
 (GEARS_L-R_UP_LOCKED-info isa display-info name GEARS_L-R_UP_LOCKED screenx 1587 screeny 490) 
 (D-info isa display-info name D screenx 912 screeny 709) 
 (M-info isa display-info name M screenx 912 screeny 685) 
 (Y-info isa display-info name Y screenx 912 screeny 661) 
 (SEC-info isa display-info name SEC screenx 912 screeny 637) 
 (MIN-info isa display-info name MIN screenx 912 screeny 613) 
 (HRS-info isa display-info name HRS screenx 912 screeny 589) 
 (POWER_LEVER_ANGLE_1-info isa display-info name POWER_LEVER_ANGLE_1 screenx 912 screeny 904) 
 (POWER_LEVER_ANGLE_2-info isa display-info name POWER_LEVER_ANGLE_2 screenx 912 screeny 880) 
 (POWER_LEVER_ANGLE_3-info isa display-info name POWER_LEVER_ANGLE_3 screenx 912 screeny 856) 
 (POWER_LEVER_ANGLE_4-info isa display-info name POWER_LEVER_ANGLE_4 screenx 912 screeny 832) 
 (A_LOT_OF_BUTTONS-info isa display-info name A_LOT_OF_BUTTONS screenx 567 screeny 133) 
;; the list of items that are to be attended in a routine loop 
(ALTITUDE-0 ISA list-info current-on-list ALTITUDE next-on-list SPEED) 
 (SPEED-1 ISA list-info current-on-list SPEED next-on-list ALTITUDE) 
 
)

(p set-default-values ;; start model, set imaginal chunk
    =goal>
      state     set-default-val
    ?imaginal>
      state     free
   ==>
    @imaginal>
	  speed 	 0 
	  altitude 	 0 
	-goal>
	-imaginal>
 )

; (add chunk into retrieval buffer some-item-on-list  =current)
 
 (p retrieve-item-on-list ;; first time, start retrieval
     ?imaginal>
       buffer    empty
     ?retrieval>
       state     free
       buffer    empty
     ==>
     +imaginal>
      +retrieval>
        - next-on-list    nil
   )
 
   (p retrieve-loc-if-next-retrieved
       =imaginal>
       =retrieval>
         next-on-list  =current
    ==>
       =imaginal>
         current  =current
       +retrieval>
         name  =current
   )
 
   (p scan-if-loc-retrieved
       =retrieval>
         name =current
         screenx     =screenx
         screeny     =screeny
       ?visual>
         state     free
       ?visual-location>
         state     free
       =imaginal>
         current  =current
     ==>
      ;; length of value in pixels (1 character is 7 pixels)
       !bind! =maxx (+ =screenx 35)
       !bind! =minx (- =screenx 35)
      +visual>
         clear     t ;; Stop visual buffer from updating without explicit requests
       +visual-location>
         <= screen-x =maxx
         >= screen-x =minx
         screen-y   =screeny
       -retrieval>
       =imaginal>
   )
 
   (p attend-if-loc-scanned
       =imaginal>
         current    =current
       =visual-location>
       ?visual>
         state     free
       ?retrieval>
         state     free
         buffer    empty
     ==>
     +visual>
       cmd       move-attention
       screen-pos =visual-location
     +retrieval>
         current-on-list  =current
     =imaginal>
 
   )
 
 
   (p update-if-item-retrieved
      =retrieval>
         current-on-list  =current
         next-on-list      =next
       =imaginal>
       =visual>
         value     =val
     ==>
       =imaginal>
         =current  =val
       ; -imaginal>
       +retrieval>
         name     =next
       !output! (GDR +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Retrieval
       successful. Display =current is updated with =val)
   )
 
 ; (spp retrieve-item-on-list :u 3)
 (spp scan-if-loc-retrieved :u 10)
 (spp attend-if-loc-scanned :u 13)
 (spp update-if-item-retrieved :u 15)



)