(p set-default-values ;; start model, set imaginal chunk
    =goal>
      state     set-default-val
    ?imaginal>
      state    free
      buffer   empty
   ==>
    +imaginal>
      isa collector
      DICT_OF_TEMP_VAL
	=goal>
      state    idle
)