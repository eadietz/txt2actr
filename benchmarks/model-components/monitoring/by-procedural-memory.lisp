(p retrieve-display ;; START model, set imaginal chunk and retrieve display loc
    =goal>
      state     RETRIEVING
      next      =display
    ?retrieval>
      state     free
    ?visual>
      state     free
    ?visual-location>
      state     free
  ==>
    +visual>
      clear     t
    @visual-location>
    +retrieval>
      info      =display
    =goal>
      state     IDLE
      next      =display
 )

;;; ############# Routine productions #############
;;; Scan and update imaginal buffer on speed and altitude in alternating order

(p scan-primary-flight-display ;; Shift visual attention to display
    =goal>
      state     IDLE
      next      =display
    =retrieval>
      info      =display
      screenx   =x
      screeny   =y
    =imaginal>
     - speed    nil
    ?visual>
      state     free
    ?visual-location>
      state     free
  ==>
    +visual>
      clear     t ;; Stop visual buffer from updating without explicit requests
    +visual-location>
      >= screen-x  =x
      screen-x  lowest
      screen-y  =y
    =imaginal>
    =goal>
      state     IDLE
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
    =goal>
 )

(p update-display ;; Update info in imaginal buffer
    =goal>
      state     IDLE
      next      %display-current
    =imaginal>
    =visual>
      value     =val
  ==>
    @visual-location>
    @visual>
    =imaginal>
      speed     =val
    =goal>
      state     RETRIEVING
      next      %display-next
  !output! ("update" %display-current)
 )