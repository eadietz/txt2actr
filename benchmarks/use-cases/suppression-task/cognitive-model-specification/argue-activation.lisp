
; declarative memory

; arg-1 used to store position of (first) argument in imaginal
; arg-2 used to store position of (second; counter of first) argument in imaginal
(define-chunks
(arg-1)
(arg-2)
(SUFFICIENT)
(NECESSARY)
)
; 'conversion' from string (word, e.g. "essay") to chunk (context, can be either SUFFICIENT or NECESSARY)
(chunk-type meaning word context)
(chunk-type argument fact position context neg-position)
(chunk-type interpretation word)

(add-dm
; if "essay" is given as a fact (together with "if essay then library", then "essay" will
; always be understood as SUFFICIENT, i.e. everyone recognizes modus ponens)
(ESSAY isa meaning word "essay" context SUFFICIENT)

(NOT-ESSAY-NEC isa meaning word "not_essay" context NECESSARY)
(NOT-ESSAY-SUF isa meaning word "not_essay" context SUFFICIENT)

(LIBRARY-NEC isa meaning word "library" context NECESSARY)
(LIBRARY-SUF isa meaning word "library" context SUFFICIENT)
(NOT-LIBRARY isa meaning word "not_library" context SUFFICIENT)

(SIMPLE-NEC isa meaning word "----------" context NECESSARY)
(SIMPLE-SUF isa meaning word "----------" context SUFFICIENT)

(OPEN-NEC isa meaning word "If_open_then_library" context NECESSARY)
(OPEN-SUF isa meaning word "If_open_then_library" context SUFFICIENT)

(TEXTBOOK-SUF isa meaning word "If_textbook_then_library" context SUFFICIENT)
(TEXTBOOK-NEC isa meaning word "If_textbook_then_library" context NECESSARY)

(arg-e-suf isa argument fact "ESSAY" position "YES" context SUFFICIENT neg-position "UNKNOWN")
(arg-e-nec isa argument fact "ESSAY" position "UNKNOWN" context NECESSARY neg-position "YES")

(arg-ne-suf isa argument fact "NOT_ESSAY" position "UNKNOWN" context SUFFICIENT neg-position "NO")
(arg-ne-nec isa argument fact "NOT_ESSAY" position "NO" context NECESSARY neg-position "UNKNOWN")

(arg-l-nec isa argument fact "LIBRARY" position "YES" context NECESSARY neg-position "UNKNOWN")
(arg-l-suf isa argument fact "LIBRARY" position "UNKNOWN" context SUFFICIENT neg-position "YES")

(arg-nl-nec isa argument fact "NOT_LIBRARY" position "UNKNOWN" context NECESSARY NEG-POSITION "NO")
(arg-nl-suf isa argument fact "NOT_LIBRARY" position "NO" context SUFFICIENT NEG-POSITION "UNKNOWN")
)


(p enough-values-to-reason
    =goal>
       state    idle
    ?retrieval>
       state  free
    =imaginal>
      - f-sentence nil
      - s-sentence nil
      - fact nil
      f-sentence =f
      s-sentence =s
      fact =fact
    ==>
    +retrieval>
      isa meaning
      word =fact
    =imaginal>
    =goal>
       state    retrieve-fact
    !output! (enough values to reason =f =s =fact +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++)
  )

;;;;;;;;;;;;;;;;;;;;;;;; RETRIEVE SENTENCE SEMANTICS ;;;;;;;;;;;;;;;;;;;;;;;;


(p activate-fact-semantics
    =goal>
       state     retrieve-fact
    =retrieval>
      word    =fact
      context =context
    =imaginal>
      s-sentence =s
   ==>
    =imaginal>
      fact =fact
      interpretation =retrieval
      context =context
    +retrieval>
      isa meaning
      word =s
    =goal>
       state     activate-context
)

(p activate-context-semantics
     =goal>
       state     activate-context
    =retrieval>
       context =context
    =imaginal>
    ==>
    =imaginal>
      context  =context
    =retrieval>
    =goal>
       state    search-for-args
)

;;;;;;;;;;;;;;;;;;;;;;;; RETRIEVE, COMPARE AND CHOOSE ARGUMENTS ;;;;;;;;;;;;;;;;;;;;;;;;

(p retrieve-argument
     =goal>
       state     search-for-args
    ?retrieval>
      state free
   =imaginal>
      fact =fact
    ==>
   =imaginal>
      arg-1 nil
      arg-2 nil
   +retrieval>
      - position nil
      fact =fact
   =goal>
       state    retrieve-counter
)

(p retrieve-counter
     =goal>
       state     retrieve-counter
   =imaginal>
   =retrieval>
      fact         =fact
      position     =position
      neg-position =neg-position
    ==>
   =imaginal>
      arg-1   =position
   +retrieval>
      fact =fact
      neg-position =position
   =goal>
       state    imagine-counter
)

(p imagine-counter
   =goal>
       state    imagine-counter
   =retrieval>
      position     =position
   =imaginal>
  ==>
   =imaginal>
      arg-2    =position
   =retrieval>
   =goal>
       state    retrieve-most-likely
)

(p retrieve-most-likely-arg
   =goal>
       state    retrieve-most-likely
   =retrieval>
   =imaginal>
      fact =fact
      - arg-1   nil
      - arg-2   nil
  ==>
   =imaginal>
   +retrieval>
      fact =fact
      - position nil
   =goal>
       state    choose-strongest
)


(p choose
   =goal>
    state       choose-strongest
   =retrieval>
      position =val
      fact     =fact
      context     =context
   =imaginal>
    value  nil
    arg-1   =arg1
    arg-2   =arg2
  ==>
   =retrieval>
   =imaginal>
     value =val
  =goal>
     state prepare-mouse
  !eval! ("add_content" (list =fact =context =arg1 =arg2 =retrieval))
)


; sets the base level activation for library as understood
; as necessary higher (1.5) then as understood
; as sufficient (1)
(set-base-levels (OPEN-NEC 2.1))
(set-base-levels (OPEN-SUF 1))
(set-base-levels (TEXTBOOK-SUF 1.9))
(set-base-levels (TEXTBOOK-NEC 0))

