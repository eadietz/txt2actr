(clear-all)
(define-model driving-task
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


(define-chunks ;; define the chunk for each item (label) 
(car_normal) 
(car_brake) 
(car_hold) 
(backlight_1) 
(backlight_2) 
(car_collision) 
(react_emg) 
(time) 
)

(add-dm (goal isa goal state set-default-val)) 
 (goal-focus goal) 


(add-dm ;; the location specification for each item (label) value 
 (car_normal-info isa display-info name car_normal screen-x 442 screen-y 334) 
 (car_brake-info isa display-info name car_brake screen-x 442 screen-y 310) 
 (car_hold-info isa display-info name car_hold screen-x 442 screen-y 286) 
 (backlight_1-info isa image-info name backlight_1 screen-x 470 screen-y 435) 
 (backlight_2-info isa image-info name backlight_2 screen-x 860 screen-y 435) 
 (car_collision-info isa display-info name car_collision screen-x 467 screen-y 694) 
 (react_emg-info isa display-info name react_emg screen-x 467 screen-y 670) 
 (time-info isa display-info name time screen-x 732 screen-y 648) 
;; the list of items that are to be attended in a routine loop 
(car_normal-0 ISA list-info current-on-list car_normal next-on-list car_brake) 
 (car_brake-1 ISA list-info current-on-list car_brake next-on-list car_normal) 
 
)

(p set-default-values ;; start model, set imaginal chunk
    =goal>
      state     set-default-val
    ?imaginal>
      buffer    empty
   ==>
    +imaginal>
	  car_normal 	 0 
	  car_brake 	 0 
	  name 	 nil 
	=goal>
      state    start
)


(set-buffer-chunk 'retrieval 'car_normal-info) 
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