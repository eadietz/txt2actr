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
(chunk-type goal state next) 
(chunk-type display-info name screenx screeny) 
(chunk-type button-info name screenx screeny) 
(chunk-type image-info name screenx screeny) 
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
 (car_normal-info isa display-info name car_normal screenx 442 screeny 334) 
 (car_brake-info isa display-info name car_brake screenx 442 screeny 310) 
 (car_hold-info isa display-info name car_hold screenx 442 screeny 286) 
 (backlight_1-info isa image-info name backlight_1 screenx 470 screeny 435) 
 (backlight_2-info isa image-info name backlight_2 screenx 860 screeny 435) 
 (car_collision-info isa display-info name car_collision screenx 467 screeny 694) 
 (react_emg-info isa display-info name react_emg screenx 467 screeny 670) 
 (time-info isa display-info name time screenx 732 screeny 648) 
;; the list of items that are to be attended in a routine loop 
(car_normal-0 ISA list-info current-on-list car_normal next-on-list car_brake) 
 (car_brake-1 ISA list-info current-on-list car_brake next-on-list car_normal) 
 
)

(p set-default-values ;; start model, set imaginal chunk
    =goal>
      state     set-default-val
    ?imaginal>
      state     free
   ==>
    @imaginal>
	  car_normal 	 0 
	  car_brake 	 0 
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
       +retrieval>
         current-on-list  =current
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