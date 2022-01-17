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
       > ALTITUDE 10
       < ALTITUDE 20
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