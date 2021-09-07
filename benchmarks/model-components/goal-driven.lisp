(add-dm
(roll-0 ISA list-info current-on-list ROLL next-on-list PTCH)
 (pitch-1 ISA list-info current-on-list PTCH next-on-list ROLL)
)
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
       state     free
    ==>
     +retrieval>
       - next-on-list    nil
     =goal>
 )



(p retrieve-item-coordinates
     =goal>
       state  idle
    ?imaginal>
      state    free
     ?retrieval>
       state    free
     =retrieval>
       next-on-list    =name
    ==>
     +retrieval>
       name    =name
      +imaginal>
        name  nil
     =goal>
)
