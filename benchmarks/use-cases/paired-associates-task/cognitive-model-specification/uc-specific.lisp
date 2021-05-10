
(chunk-type pair probe answer)

(add-dm
 (start isa chunk) (attending-target isa chunk)
 (attending-probe isa chunk)
 (testing isa chunk) (read-study-item isa chunk)
 )


(p attend-probe
    =goal>
      isa      goal
      state    start
    =visual-location>
    ?visual>
     state     free
   ==>
    +visual>
      cmd      move-attention
      screen-pos =visual-location
    =goal>
      state    attending-probe
)

(p read-probe
    =goal>
      isa      goal
      state    attending-probe
    =visual>
      isa      visual-object
      value    =val
    ?imaginal>
      state    free
    =imaginal>
   ==>
    !output! (probe =val)
    +imaginal>
      probe    =val
    +retrieval>
      probe    =val
    =goal>
      state    testing
)

(p recall
    =goal>
      isa      goal
      state    testing
    =retrieval>
      answer   =ans
    ?manual>
      state    free
    ?visual>
      state    free
   ==>
    !output! (answer =ans)
    +manual>
      cmd      press-key
      key      =ans
    =goal>
      state    read-study-item
    +visual>
      cmd      clear
)


(p cannot-recall
    =goal>
      isa      goal
      state    testing
    ?retrieval>
      buffer   failure
    ?visual>
      state    free
   ==>
    =goal>
     state    read-study-item
    +visual>
     cmd      clear
)

(p detect-study-item
    =goal>
      isa      goal
      state    read-study-item
    =visual-location>
    ?visual>
      state    free
   ==>
    +visual>
      cmd      move-attention
      screen-pos =visual-location
    =goal>
      state    attending-target
)


(p associate
    =goal>
      isa      goal
      state    attending-target
    =visual>
      isa      visual-object
      value    =val
    ?imaginal>
      state    free
   =imaginal>
      probe    =probe
    ?visual>
      state    free
  ==>
   +imaginal>
      answer   =val
   =goal>
      state    start
   +visual>
      cmd      clear
)


(goal-focus goal)
