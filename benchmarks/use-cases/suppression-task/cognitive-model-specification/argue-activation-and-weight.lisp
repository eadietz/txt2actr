
(define-chunks
(ARG-1)
(ARG-2)
)
(chunk-type meaning word context)
(chunk-type argument fact position context strength neg-position)
(chunk-type interpretation word)

(add-dm
(SUFFICIENT isa interpretation word "SUFFICIENT")
(NECESSARY isa interpretation word "NECESSARY")

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

(arg-e-suf-strong isa argument fact "ESSAY" position "YES" context SUFFICIENT strength 0.5 neg-position "UNKNOWN")
(arg-e-suf-weak isa argument fact "ESSAY" position "YES" context NECESSARY strength 0.1 neg-position "UNKNOWN")

(arg-e-nec-strong isa argument fact "ESSAY" position "UNKNOWN" context NECESSARY strength 0.6 neg-position "YES")
(arg-e-nec-weak isa argument fact "ESSAY" position "UNKNOWN" context SUFFICIENT strength 0.1 neg-position "YES")

(arg-ne-suf-strong isa argument fact "NOT_ESSAY" position "UNKNOWN" context SUFFICIENT strength 0.5 neg-position "NO")
(arg-ne-suf-weak isa argument fact "NOT_ESSAY" position "UNKNOWN" context NECESSARY strength 0.1 neg-position "NO")

(arg-ne-nec-strong isa argument fact "NOT_ESSAY" position "NO" context NECESSARY strength 0.6 neg-position "UNKNOWN")
(arg-ne-nec-weak isa argument fact "NOT_ESSAY" position "NO" context SUFFICIENT strength 0.1 neg-position "UNKNOWN")


(arg-l-nec isa argument fact "LIBRARY" position "YES" context NECESSARY strength 0.6 neg-position "UNKNOWN")
(arg-l-suf isa argument fact "LIBRARY" position "UNKNOWN" context SUFFICIENT strength 0.5 neg-position "YES")

(arg-nl-nec isa argument fact "NOT_LIBRARY" position "UNKNOWN" context NECESSARY strength 0.6 NEG-POSITION "NO")
(arg-nl-suf isa argument fact "NOT_LIBRARY" position "NO" context SUFFICIENT strength 0.5 NEG-POSITION "UNKNOWN")
)

(set-base-levels (NOT-ESSAY-NEC 1.2))
(set-base-levels (NOT-ESSAY-SUF 1))
(set-base-levels (OPEN-NEC 2.2))
(set-base-levels (OPEN-SUF 1))

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


(p retrieve-fact-semantics
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
      strength     =val
    ==>
   =imaginal>
      arg-1        =retrieval
      pos-1        =position
      strength-1   =val
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
      strength     =val
   =imaginal>
  ==>
   =imaginal>
      arg-2         =retrieval
      pos-2         =position
      strength-2    =val
   =retrieval>
   =goal>
       state    compare-strength
)


(p arg-1-stronger
   =goal>
      state    compare-strength
   =imaginal>
      strength-1   =val-1
      < strength-2 =val-1
      arg-1        =arg-1
      pos-1         =pos-1
      pos-2         =pos-2
      context      =context
      fact         =fact
   ==>
   =imaginal>
     value =pos-1
  =goal>
     state prepare-mouse
  !eval! ("add_content" (list =fact =context =pos-1 =pos-2 =arg-1))
)


(p arg-2-stronger
   =goal>
      state    compare-strength
   =imaginal>
      strength-1 =val-1
      > strength-2 =val-1
      arg-2 =arg-2
      pos-1 =pos-1
      pos-2 =pos-2
      context =context
      fact =fact
   ==>
   =imaginal>
     value =pos-2
  =goal>
     state prepare-mouse
  !eval! ("add_content" (list =fact =context =pos-1 =pos-2 =arg-2))
)

(p equally-strong
   =goal>
      state    compare-strength
   =retrieval>
   =imaginal>
      strength-1 =val
      strength-2 =val
      fact =fact
   ==>
   +retrieval>
      fact =fact
      - position nil
   =imaginal>
  =goal>
     state choose-w-highest-activation
)

(p choose
   =goal>
    state       choose-w-highest-activation
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

#|(p retrieve-most-likely-arg
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
)|#

