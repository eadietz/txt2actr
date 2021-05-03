(p scan-if-scene-changed
    ?visual-location>
      state     free
    ?visual>
      state     free
      scene-change  t
  ==>
    +visual-location>
      :attended new
)

 (p attend-item-if-loc-scanned
     =visual-location>
       isa       visual-location
       screen-x  =screenx
       screen-y  =screeny
     ?visual>
       state     free
     ?retrieval>
       state     free
   ==>
     ;; length of value in pixels (1 character is 7 pixels)
     !bind! =maxx (+ =screenx 35)
     !bind! =minx (- =screenx 35)
     ;; height of word in pixels (e.g. fontsize 12 is 16px)
     !bind! =maxy (+ =screeny 16)
     !bind! =miny (- =screeny 16)
     +visual>
       cmd           move-attention
       screen-pos    =visual-location
     +retrieval>
       <= screenx =maxx
       >= screenx =minx
       <= screeny  =maxy
       >= screeny  =miny
 )

 (p update-if-item-retrieved
     =retrieval>
       name      =name
     ?imaginal>
      state     free
     ?visual-location>
       state     free
     =visual>
       value     =val
   ==>
     +imaginal>
       =name     =val
   !output! (DDR +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Retrieval
   successful. Display =name is updated with =val)
 )

(spp attend-item-if-loc-scanned :u 10)
(spp update-if-item-retrieved :u 13)