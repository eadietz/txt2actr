
(sgp :seed (200 4))

;(add-dm
; (start isa chunk) (attending-target isa chunk)
; (attending-probe isa chunk)
; (testing isa chunk) (read-study-item isa chunk)
; )

(p attend-probe
    =goal>
      isa      goal
      state    start
    ?imaginal>
      state    free
    =visual-location>
    ?visual>
      scene-change t
      state        free
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
      value    =val
    ?imaginal>
      state    free
    ?retrieval>
      state    free
   ==>
    +imaginal>
      isa      collector
      probe    =val
    +retrieval>
      isa      collector
      probe    =val
    =goal>
      state    testing
)

(p recall
    =goal>
      isa      goal
      state    testing
    =retrieval>
      isa      collector
      answer   =ans
    ?manual>
      state    free
    ?visual>
      state    free
   ==>
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
      value    =val
   =imaginal>
      isa      collector
      probe    =probe
    ?visual>
      state    free
  ==>
   =imaginal>
      answer   =val
   -imaginal>
   =goal>
      state    start
   +visual>
      cmd      clear
)


; (goal-focus goal)

(spp attend-probe :u 0.99)
;(spp read-probe :u 0)
;(spp recall :u 0)
;(spp detect-study-item :u 0)
