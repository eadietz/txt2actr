(clear-all)
(define-model suppression-task
 (sgp
   :v nil ;; -model-output
   :esc t ; enables subsymbolic computations
   :rt -2.5  ; minimum activation threshold
   :ol t    ; optimized learning parameter that approximates learning rule
   :act nil   ; prints out activation trace
   :ans 0.2 ; instantaneous/ transient noise for each retrieval request, recommended range [0.2,0.8]
   :pas nil ; permanent noise associated with each chunk when entered in dm
   :mas 5 ; spreading activation
   :nsji nil ; allows negative sji values from the strength of association calculation
   :bll nil ; base-level learning enabled, also sets decay d
   ;:retrieval-activation 5.0
   ;:imaginal-activation 0
   :show-focus t
   ;:time-master-start-increment 1.0
   ;:trace-detail low
   ;:ul t
   ; :egs 0.95 ; noise in utility based choosing production rules
   ;:unstuff-aural-location t
   ;:visual-activation 10
   ;:tone-detect-delay 1.0
   :needs-mouse t
   )

(sgp :seed (200 4))


(add-word-characters ".")
(add-word-characters "_")
(set-visloc-default)

;; ---> insert additional model modules after here


;; Define the chunk types for the chunks 
(chunk-type goal state) 
(chunk-type display-info name screen-x screen-y) 
(chunk-type button-info name screen-x screen-y) 
(chunk-type image-info name screen-x screen-y) 
(chunk-type sound-info name) 
(chunk-type sa-level val) 
(chunk-type SA event aoi eeg action1 action2 action3 time) 
(chunk-type list-info current-on-list next-on-list) 
(chunk-type collector name probe associate) 


(define-chunks ;; define the chunk for each item (label) 
(s-sentence) 
(f-sentence) 
(fact) 
(yes) 
(no) 
(unknown) 
)

(add-dm (starting-goal isa goal state idle)) 
 (goal-focus starting-goal) 


(add-dm ;; the location specification for each item (label) value 
 (s-sentence-info isa display-info name s-sentence screen-x 517.0 screen-y 125.5) 
 (f-sentence-info isa display-info name f-sentence screen-x 517.0 screen-y 101.5) 
 (fact-info isa display-info name fact screen-x 517.0 screen-y 655.5) 
 (yes-info isa button-info name yes screen-x 1025.0 screen-y 665.0) 
 (no-info isa button-info name no screen-x 1025.0 screen-y 715.0) 
 (unknown-info isa button-info name unknown screen-x 1025.0 screen-y 765.0) 
)

(add-dm
 (info-0 ISA list-info current-on-list f-sentence next-on-list s-sentence)
 (info-1 ISA list-info current-on-list s-sentence next-on-list fact)
 (info-2 ISA list-info current-on-list fact next-on-list f-sentence)
 )
 
 (set-all-base-levels 100000 -1000)
 
 (p retrieve-item-from-list
      =goal>
        state    idle
      ?retrieval>
        state     free
     ?imaginal>
       state    free
     ==>
      +retrieval>
        - current-on-list    nil
      +imaginal>
       f-sentence nil
       s-sentence nil
       fact     nil
      =goal>
  )
 
  (p scan-if-item-retrieved
       =goal>
        state    idle
       =retrieval>
         current-on-list       =name
       ?visual-location>
         state     free
       ?visual>
         state     free
       =imaginal>
     ==>
      +visual-location>
         color =name
     +visual>
         clear     t ;; Stop visual buffer from updating without explicit requests
      =retrieval>
     =goal>
       state    attend
     =imaginal>
     )
 
 (p attend
     =goal>
       state    attend
     =visual-location>
     ?visual>
        state   free
     =imaginal>
     ==>
     =visual-location>
     +visual>
       cmd       move-attention
       screen-pos =visual-location
     =goal>
       state    read
     =imaginal>
   )
 
   (p read-info
      =goal>
        state     read
      =retrieval>
       current-on-list  =current
       next-on-list  =next
       =visual>
         value     =val
     =imaginal>
     ==>
     =imaginal>
         =current =val
     +retrieval>
       current-on-list  =next
     =goal>
       state    idle
   )
 
 #|(p retrieve-item-coordinates
      =goal>
        state  idle
     ?imaginal>
       state    free
      ?retrieval>
        state    free
      =retrieval>
        next-on-list    =name
     ==>
      +retrieval>
        name    =name
      +imaginal>
       type context
       f-sentence nil
       s-sentence nil
       fact     nil
      =goal>
 )|#



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
 
 
 ; sets the base level activation for OPEN and TEXTBOOK as understood
 ; as necessary higher (1.5) then as understood as sufficient (1)
 (set-base-levels (OPEN-NEC 2.1))
 (set-base-levels (OPEN-SUF 1))
 (set-base-levels (TEXTBOOK-SUF 1.9))
 (set-base-levels (TEXTBOOK-NEC 0))


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




 )