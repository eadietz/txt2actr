(p start-retrieval ;; first time, start retrieval
     ?retrieval>
       state     free
    ?imaginal>
      buffer    empty
   ==>
    +retrieval>
      - next-on-list    nil
 )

 (p retrieve-next-on-list
     =retrieval>
       next-on-list  =next
  ==>
     +retrieval>
       info          =next
 )

 (p gdr-retrieve-then-attend-display-info
     =retrieval>
       info      =current
       screenx   =screenx
       screeny   =screeny
     ?visual>
       state     free
     ?visual-location>
       state     free
   ==>
     !bind! =screenxmax (+ =screenx 18) ; just a guess on how long the value (in pixels) can be maximally (1 character is 7 pixels)
     +visual>
       clear     t ;; Stop visual buffer from updating without explicit requests, clear current visual buffer
     +visual-location>
       >= screen-x   =screenx
       ; screen-x   =screenx
       <= screen-x   =screenxmax
       screen-y      =screeny
    +retrieval>
       current-on-list  =current
 )

(p attend-flight-info ;; Attend display
    =goal>
      state     IDLE
    ?retrieval>
      buffer    empty
    =imaginal>
    =visual-location>
    ?visual>
      state     free
  ==>
    +visual>
      cmd       move-attention
      screen-pos =visual-location
    @visual-location>
    =imaginal>
 )

 (p update-value
    =retrieval>
       current-on-list  =current
       next-on-list   =next
     =imaginal>
     ?imaginal>
       state     free
     !bind! =nameToString (prin1-to-string =current)
     =visual>
       value     =val
        - value   =nameToString
        - value   ":"
        - value   "]"
        - value   "["
        - value   "."
   ==>
     =imaginal>
       =current  =val
     =retrieval>
       next-on-list   =next
     !output! (+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ attention
     successful. Display =current is updated with =val)
 )

)