
(p enough-values-to-reason
    =goal>
       - state    reason
       - state    retrieve-semantics
       - state    search-for-args
       - state    compare-args
       - state    choose-strongest
       value    nil
    =imaginal>
      type context
      - f-sentence nil
      - s-sentence nil
      - fact nil
      f-sentence =f
      s-sentence =s
      fact =fact
    ==>
    =imaginal>
    =goal>
       state    retrieve-semantics
    !output! (enough values to reason =f =s =fact +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++)
  )

(spp enough-values-to-reason :u 150)

(chunk-type ARGUMENT POSITION CONTEXT val NEG-POSITION)

(add-dm
(ESSAY isa chunk name "essay" negation not-essay)
(NOT-ESSAY isa chunk name "not_essay" NEGATION ESSAY)
(simple isa chunk name "----------" NEGATION nil)
(LIBRARY isa chunk name "library" NEGATION NOT-LIBRARY)
(NOT-LIBRARY isa chunk name "not_library" NEGATION LIBRARY)
(OPEN isa chunk name "If_open_then_library" NEGATION NOT-OPEN)
(NOT-OPEN isa chunk name "If_open_then_library" NEGATION OPEN)
(TEXTBOOK isa chunk name "If_textbook_then_library" NEGATION NOT-TEXTBOOK)
(NOT-TEXTBOOK isa chunk name "If_textbook_then_library" NEGATION TEXTBOOK)
)

(add-dm
(arg-e1 type ARGUMENT fact ESSAY POSITION LIBRARY CONTEXT SIMPLE val 0.5 NEG-POSITION NOT-LIBRARY)
(arg-e2 type ARGUMENT fact ESSAY POSITION LIBRARY CONTEXT SIMPLE val 0.4 NEG-POSITION NOT-LIBRARY)
(arg-e3 type ARGUMENT fact ESSAY POSITION LIBRARY CONTEXT TEXTBOOK val 0.5 NEG-POSITION NOT-LIBRARY)
(arg-e4 type ARGUMENT fact ESSAY POSITION LIBRARY CONTEXT TEXTBOOK val 0.4 NEG-POSITION NOT-LIBRARY)
(arg-e5 type ARGUMENT fact ESSAY POSITION LIBRARY CONTEXT OPEN val 0.5 NEG-POSITION NOT-LIBRARY)
(arg-e6 type ARGUMENT fact ESSAY POSITION LIBRARY CONTEXT OPEN val 0.4 NEG-POSITION NOT-LIBRARY)

(arg-e7 type ARGUMENT fact ESSAY POSITION NOT-LIBRARY CONTEXT SIMPLE val 0.1 NEG-POSITION LIBRARY)
(arg-e8 type ARGUMENT fact ESSAY POSITION NOT-LIBRARY CONTEXT SIMPLE val 0.4 NEG-POSITION LIBRARY)
(arg-e9 type ARGUMENT fact ESSAY POSITION NOT-LIBRARY CONTEXT NOT-TEXTBOOK val 0.1 NEG-POSITION LIBRARY)
(arg-e10 type ARGUMENT fact ESSAY POSITION NOT-LIBRARY CONTEXT NOT-TEXTBOOK val 0.4 NEG-POSITION LIBRARY)
(arg-e11 type ARGUMENT fact ESSAY POSITION NOT-LIBRARY CONTEXT NOT-OPEN val 0.5 NEG-POSITION LIBRARY)
(arg-e12 type ARGUMENT fact ESSAY POSITION NOT-LIBRARY CONTEXT NOT-OPEN val 0.6 NEG-POSITION LIBRARY)

(arg-ne1 type argument fact NOT-ESSAY position LIBRARY context SIMPLE val 0.1 NEG-POSITION NOT-LIBRARY)
(arg-ne4 type argument fact NOT-ESSAY position LIBRARY context SIMPLE val 0.5 NEG-POSITION NOT-LIBRARY)
(arg-ne2 type argument fact NOT-ESSAY position LIBRARY context TEXTBOOK val 0.5 NEG-POSITION NOT-LIBRARY)
(arg-ne5 type argument fact NOT-ESSAY position LIBRARY context NOT-TEXTBOOK val 0.5 NEG-POSITION LIBRARY)
(arg-ne3 type argument fact NOT-ESSAY position LIBRARY context LIBRARY val 0.1 NEG-POSITION NOT-LIBRARY)
(arg-ne6 type argument fact NOT-ESSAY position LIBRARY context NOT-LIBRARY val 0.5 NEG-POSITION LIBRARY)

(arg-ne7 type argument fact NOT-ESSAY position NOT-LIBRARY context SIMPLE val 0.1 NEG-POSITION LIBRARY)
(arg-ne8 type argument fact NOT-ESSAY position NOT-LIBRARY context TEXTBOOK val 0.5 NEG-POSITION LIBRARY)
(arg-ne9 type argument fact NOT-ESSAY position NOT-LIBRARY context LIBRARY val 0.5 NEG-POSITION LIBRARY)
(arg-ne10 type argument fact NOT-ESSAY position NOT-LIBRARY context SIMPLE val 0.5 NEG-POSITION LIBRARY)
(arg-ne11 type argument fact NOT-ESSAY position NOT-LIBRARY context NOT-TEXTBOOK val 0.1 NEG-POSITION LIBRARY)
(arg-ne12 type argument fact NOT-ESSAY position NOT-LIBRARY context NOT-LIBRARY val 0.5 NEG-POSITION LIBRARY)
)

(set-base-levels (arg-e1 2))
(set-base-levels (arg-e2 2))
(set-base-levels (arg-e3 2))
(set-base-levels (arg-e4 2))
(set-base-levels (arg-e5 2))
(set-base-levels (arg-e6 2))
(set-base-levels (arg-e7 2))
(set-base-levels (arg-e8 2))
(set-base-levels (arg-e9 2))
(set-base-levels (arg-e10 2))
(set-base-levels (arg-e11 2))
(set-base-levels (arg-e12 2))

(set-base-levels (arg-ne1 2))
(set-base-levels (arg-ne2 2))
(set-base-levels (arg-ne3 2))
(set-base-levels (arg-ne4 2))
(set-base-levels (arg-ne5 2))
(set-base-levels (arg-ne6 2))
(set-base-levels (arg-ne7 2))
(set-base-levels (arg-ne8 2))
(set-base-levels (arg-ne9 2))
(set-base-levels (arg-ne10 2))
(set-base-levels (arg-ne11 2))
(set-base-levels (arg-ne12 2))


;;;;;;;;;;;;;;;;;;;;;;;; RETRIEVE SENTENCE SEMANTICS ;;;;;;;;;;;;;;;;;;;;;;;;


(p retrieve-fact-semantics
     =goal>
       state     retrieve-semantics
    ?retrieval>
       state  free
    =retrieval>
       - name  =fact
    =imaginal>
      fact     =fact
    ==>
    +retrieval>
      name =fact
    =imaginal>
     =goal>
       state    retrieve-semantics
)

(p retrieve-sentence-semantics
     =goal>
       state     retrieve-semantics
    ?retrieval>
       state  free
    =retrieval>
       name  =fact
       - name  =sentence
    =imaginal>
      s-sentence =sentence
    ==>
    =imaginal>
      fact  =retrieval
    +retrieval>
      name =sentence
     =goal>
       state    reason
)

;;;;;;;;;;;;;;;;;;;;;;;; PART I: ESSAY ;;;;;;;;;;;;;;;;;;;;;;;;

;; Arg with fact and sufficient prediction: {fact(essay), sufficient(essay,library)}

(p retrieve-pos
     =goal>
       state     reason
    =imaginal>
       fact      =fact
    ?retrieval>
       state  free
    =retrieval>
      name =sentence
    ==>
   =imaginal>
      context =retrieval
    +retrieval>
      type argument
   =goal>
       state    search-for-args
)

(p retrieve-opposite-pos
   =goal>
     state     search-for-args
    =retrieval>
      type argument
      position =position
      neg-position =neg-position
   =imaginal>
     =position nil
  ==>
    +retrieval>
      type argument
      position =neg-position
   =imaginal>
     =position  =val
   =goal>
     state     search-for-args
)


(p args
  =goal>
    state       search-for-args
    =retrieval>
      position =postiton
      neg-position =neg-postiton
   =imaginal>
     fact     =fact
     s-sentence =sentence
     =postiton =val
     =neg-postiton =neg-val
  ==>
  =retrieval>
  =imaginal>
  !eval! ("add_production_rule" (list =sentence =fact =postiton =val =neg-postiton =neg-val))
  !output! (argument for =postiton has strength =val and
  argument for =neg-postiton has strength =neg-val)
  =goal>
    state       choose-strongest
)

(p choose-yes
   =goal>
    state       choose-strongest
   =retrieval>
      position =postiton
      neg-position =neg-postiton
   =imaginal>
     =postiton   =val
     > =postiton =neg-val
     =neg-postiton =neg-val
  ==>
   =retrieval>
   +imaginal>
     value "yes"
  =goal>
)

(p choose-no
  =goal>
    state       choose-strongest
   =retrieval>
      position =postiton
      neg-position =neg-postiton
   =imaginal>
     =postiton   =val
     < =postiton =neg-val
     =neg-postiton =neg-val
  ==>
   =retrieval>
   +imaginal>
     value "no"
  =goal>
)

(p choose-unknown
  =goal>
    state       choose-strongest
   =retrieval>
      position =postiton
      neg-position =neg-postiton
   =imaginal>
     =postiton =val
     =neg-postiton =val
  ==>
   +imaginal>
     value "unknown"
  =goal>
)

;; Preference relations

; Part I: essay
;(spp essay-sufficient-for-libr :u 50) ; :at 10
;(spp hypo-textbook-sufficient-for-libr :u 50) ; :at 10
;(spp hypo-not-open-open-necessary-for-libr :u 50) ; :at 10
