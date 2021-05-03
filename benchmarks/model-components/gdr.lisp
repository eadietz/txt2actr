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
      -retrieval>
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
    +retrieval>
        current-on-list  =current
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