; (sgp :scene-change-threshold 1.0)

(p scan-if-scene-changed
    =goal>
      isa      goal
      state    start
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
      isa collector
      name       nil
    =goal>
      state    update
)

 (p attend-retrieve-if-location-scanned
    =goal>
      isa      goal
      state    update
     ?retrieval>
        state     free
     =visual-location>
       isa       visual-location
       screen-x  =screenx
       screen-y  =screeny
       ;color     =name
    ?visual>
      state     free
   ==>
     ;; length of value in pixels (1 character is 7 pixels), the margin needs to be adapted according to the environment
     !bind! =maxx (+ =screenx 20)
     !bind! =minx (- =screenx 20)
     ; height of word in pixels (e.g. fontsize 12 is 16px)
     !bind! =maxy (+ =screeny 16)
     !bind! =miny (- =screeny 16)
     +visual>
       cmd           move-attention
       screen-pos    =visual-location
     +retrieval>
       isa display-info
       <= screen-x =maxx
       >= screen-x =minx
       <= screen-y =maxy
       >= screen-y =miny
    =goal>
    =visual-location
    ;@visual-location>
 )

 (p dd-visual-ip-update-if-item-retrieved
    =goal>
      isa      goal
      state    update
     =visual>
       value     =val
     =retrieval>
       name      =name
    ?imaginal>
      state    free
   =imaginal>
      ;isa collector
      ;name      =name
    ?visual>
      state    free
   ==>
      @imaginal>
        isa collector
        =name  =val
     +imaginal>
      isa collector
      name       nil
    =goal>
      state    start
    +visual>
      cmd      clear
      !output! (data-driven update +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Attended and retrieved
      successfully. Display =name is updated with =val)
 )

(p handle-find-loc-failure
     ?visual-location>
       state     error
      ?visual>
        state     free
    =imaginal>
        state    free
    ==>
    +visual>
        clear     t
 )

; specify production rule priorities for DDAR
(spp scan-if-scene-changed :u 1)
;(spp attend-retrieve-if-location-scanned :u 1)
;(spp dd-visual-ip-update-if-item-retrieved :u 5)
