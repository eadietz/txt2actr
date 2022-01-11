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
(spp scan-if-scene-changed :u 100)
; (spp scan-if-scene-did-not-change :u 1)


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
      =imaginal>
        =current  =val
        name  nil
    +visual>
        cmd    clear
    =goal>
      state    idle
      !output! (data-driven update +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Attended and retrieved
      successfully. Display =current is updated with =val)
      !eval! ("pass_data_to_sim" (list =current =val))
 )


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