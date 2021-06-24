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