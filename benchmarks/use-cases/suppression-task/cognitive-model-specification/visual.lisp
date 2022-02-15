(add-dm
(info-0 ISA list-info current-on-list f-sentence next-on-list s-sentence)
(info-1 ISA list-info current-on-list s-sentence next-on-list fact)
(info-2 ISA list-info current-on-list fact next-on-list f-sentence)
)

(set-all-base-levels 100000 -1000)

(p retrieve-item-from-list
     =goal>
       state    idle
     ?retrieval>
       state     free
    ?imaginal>
      state    free
    ==>
     +retrieval>
       - current-on-list    nil
     +imaginal>
      f-sentence nil
      s-sentence nil
      fact     nil
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
      =imaginal>
    ==>
     +visual-location>
        color =name
    +visual>
        clear     t ;; Stop visual buffer from updating without explicit requests
     =retrieval>
    =goal>
      state    attend
    =imaginal>
    )

(p attend
    =goal>
      state    attend
    =visual-location>
    ?visual>
       state   free
    =imaginal>
    ==>
    =visual-location>
    +visual>
      cmd       move-attention
      screen-pos =visual-location
    =goal>
      state    read
    =imaginal>
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
  )

#|(p retrieve-item-coordinates
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
      type context
      f-sentence nil
      s-sentence nil
      fact     nil
     =goal>
)|#
