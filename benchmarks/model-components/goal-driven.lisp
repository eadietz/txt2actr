(p retrieve-item-from-list
     =goal>
       state    idle
     ?retrieval>
       state     free
    ==>
     +retrieval>
       - current-on-list    nil
     =goal>
 )

 (p scan-if-item-retrieved
      =goal>
       state    idle
      =retrieval>
        current-on-list       =name
      ?visual-location>
        state     free
      ?visual>
        state     free
      ?imaginal>
        state    free
    ==>
     +visual-location>
        color =name
    +visual>
        clear     t ;; Stop visual buffer from updating without explicit requests
     =retrieval>
    =goal>
      state    attend
     +imaginal>
        =name  nil
    )

(p attend
    =goal>
      state    attend
    =visual-location>
    ?visual>
       state   free
    ==>
    =visual-location>
    +visual>
      cmd       move-attention
      screen-pos =visual-location
    =goal>
      state    read
  )

  (p read-info
     =goal>
       state     read
     =retrieval>
      current-on-list  =current
      next-on-list  =next
      =visual>
        value     =val
    =imaginal>
    ==>
    =imaginal>
        =current =val
    +retrieval>
      current-on-list  =next
    =goal>
      state    idle
      !output! (goal-driven update +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Retrieved and attended
      successfully. Display =current is updated with =val)
  )
