
(p prepare-mouse
     =goal>
       state    prepare-mouse
    =imaginal>
     value =val
   ==>
   -imaginal>
   +visual-location>
       kind  oval
       value =val
     =goal>
       state    move-mouse
)

(p move-mouse
   =goal>
      state      move-mouse
   =visual-location>
   ?visual>
      state      free
   ?manual>
      state      free
  ==>
   +visual>
      isa        move-attention
      screen-pos =visual-location
   =goal>
      state      click-mouse
   +manual>
      isa        move-cursor
      loc        =visual-location)

(p click-mouse
   =goal>
      state  click-mouse
   ?manual>
      state  free
  ==>
   -goal>
   +manual>
      isa    click-mouse
)
