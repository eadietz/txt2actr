(p scan-if-scene-changed
    ?imaginal>
      state    free
    ?visual-location>
      state     free
    ?visual>
       state     free
       scene-change t
  ==>
    +visual-location>
      :attended new
    +imaginal>
      name       nil
)

 (p attend-retrieve-if-location-scanned
     ?retrieval>
        state     free
    =imaginal>
      name      nil
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
     ;!bind! =maxy (+ =screeny 16)
     ;!bind! =miny (- =screeny 16)
     +visual>
       cmd           move-attention
       screen-pos    =visual-location
    +visual>
        clear     t ;; Stop visual buffer from updating without explicit requests
     +retrieval>
       ;name   =name
       isa display-info
       <= screen-x =maxx
       >= screen-x =minx
       = screen-y  =screeny
       ; >= screen-y  =miny
    =imaginal>
 )

 (p dd-visual-ip-update-if-item-retrieved
     =retrieval>
       name      =name
    =imaginal>
      name      nil
    ?imaginal>
      state    free
     =visual>
       value     =val
   ==>
      =imaginal>
        =name  =val
   !output! (data-driven update +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Attended and retrieved
      successfully. Display =name is updated with =val)
 )


; specify production rule priorities for DDAR
;(spp scan-if-scene-changed :u 10)
;(spp attend-retrieve-if-scanned :u 10)
;(spp ddar-update-if-retrieved :u 7)