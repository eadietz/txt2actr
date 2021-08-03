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
(chunk-type collector name probe associate) 


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
      state    free
      buffer   empty
   ==>
    +imaginal>
      isa collector
	  car_normal 	 0 
	  car_brake 	 0 
	  name 	 nil 
	=goal>
      state    idle
)


(set-buffer-chunk 'retrieval 'car_normal-info) 

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


(p scan-if-scene-changed
     =goal>
       state    idle
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
       name       nil
     =goal>
       state    dd-attend
 )
 
  (p attend-retrieve-if-location-scanned
     =goal>
       state    dd-attend
      ?retrieval>
         state     free
      =visual-location>
        isa       visual-location
        screen-x  =screenx
        screen-y  =screeny
     ?visual>
       state     free
    ==>
      ;; length of value in pixels (1 character is 7 pixels), the margin needs to be adapted according to the environment
      !bind! =maxx (+ =screenx 50)
      !bind! =minx (- =screenx 50)
      ; height of word in pixels (e.g. fontsize 12 is 16px)
      !bind! =maxy (+ =screeny 16)
      !bind! =miny (- =screeny 16)
      +visual>
        cmd           move-attention
        screen-pos    =visual-location
      +retrieval>
        ; isa display-info
        - name     nil
        <= screen-x =maxx
        >= screen-x =minx
        ; screen-y  =screeny ; this is for use case driving-task and flight-task
        <= screen-y =maxy  ;these two conditions if for use case paired-associates-task
        >= screen-y =miny
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
       =imaginal>
         =current  =val
         name  nil
     +visual>
         cmd    clear
     =goal>
       state    idle
       !output! (data-driven update +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Attended and retrieved
       successfully. Display =current is updated with =val)
  )
 
 ; specify production rule priorities for data driven component
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