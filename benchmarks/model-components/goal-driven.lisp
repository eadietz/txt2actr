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