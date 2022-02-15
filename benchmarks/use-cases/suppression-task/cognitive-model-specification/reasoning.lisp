
(p enough-values-to-reason
    =goal>
       - state    reason
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
       state    reason
    !output! (enough values to reason =f =s =fact +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++)
  )


(spp enough-values-to-reason :u 150)


;;;;;;;;;;;;;;;;;;;;;;;; PART I: ESSAY ;;;;;;;;;;;;;;;;;;;;;;;;

;; Arg with fact and sufficient prediction: {fact(essay), sufficient(essay,library)}
(p essay-sufficient-for-libr
     =goal>
       state     reason
    =imaginal>
      f-sentence "If_essay_then_library"
      s-sentence =s-sentence
      fact       "essay"
      interpretation nil
    ==>
     =imaginal>
      interpretation sufficient
      fact t
      value "yes"
     !eval! ("add_production_rule" (list =s-sentence "essay" "yes" "sufficient"))
     =goal>
)

;; Arg with hypothesis and sufficient prediction {hypothesis(textbook), sufficient(textbook, library)}
(p hypo-textbook-sufficient-for-libr
     =goal>
       state     reason
    =imaginal>
      f-sentence "If_essay_then_library"
      s-sentence "If_textbook_then_library"
      fact       "essay"
      interpretation nil
    ==>
      =imaginal>
      interpretation sufficient
      conflicting-hypo f
      value "yes"
     !eval! ("add_production_rule" (list "If_textbook_then_library" "essay" "yes" "sufficient"))
      =goal>
)

(p hypo-not-open-open-necessary-for-libr
     =goal>
       state     reason
    =imaginal>
      f-sentence "If_essay_then_library"
      s-sentence "If_open_then_library"
      fact       "essay"
      interpretation nil
    ==>
      =imaginal>
      interpretation necessary
      value "unknown"
      =goal>
    !eval! ("add_production_rule" (list "If_open_then_library" "essay" "unknown" "necessary"))
)


;;;;;;;;;;;;;;;;;;;;;;;; PART I: NOT ESSAY ;;;;;;;;;;;;;;;;;;;;;;;;

;; Argument with fact and necessary prediction {fact(not essay), necessary(not essay,not library)}
(p no-essay-necessary-for-libr
     =goal>
       state     reason
    =imaginal>
      f-sentence "If_essay_then_library"
      s-sentence =s-sentence
      - s-sentence "If_textbook_then_library"
      fact       "not_essay"
      interpretation nil
    ==>
      =imaginal>
      interpretation necessary
      fact t
      value "no"
      =goal>
    !eval! ("add_production_rule" (list =s-sentence "not_essay" "no" "necessary"))
)

;; Argument with hypothesis and necessary prediction {fact(not open), necessary(not open,not library)}
(p no-essay-hypo-open-necessary-for-libr
     =goal>
       state     reason
    =imaginal>
      f-sentence "If_essay_then_library"
      s-sentence "If_open_then_library"
      interpretation nil
      fact       "not_essay"
    ==>
      =imaginal>
      interpretation necessary
      value "no"
      =goal>
    !eval! ("add_production_rule" (list "If_open_then_library" "not_essay" "no" "necessary"))
)

;; Argument with hypothesis and exeogenous explanation {hypothesis(alternative), sufficient(alternative, library)}
(p hypo-sufficient-for-libr
     =goal>
       state     reason
    =imaginal>
      f-sentence "If_essay_then_library"
      s-sentence =s-sentence
      fact       "not_essay"
      interpretation nil
    ==>
      =imaginal>
      interpretation sufficient
      conflicting-hypo f
      value "unknown"
      =goal>
    !eval! ("add_production_rule" (list =s-sentence "not_essay" "unknown" "sufficient"))
)

;;;;;;;;;;;;;;;;;;;;;;;; PART II: Library ;;;;;;;;;;;;;;;;;;;;;;;;

;; Argument fact with sufficient explanation{fact(library), sufficient explanation(library, essay)}
(p hypo-essay-sufficient-explanation-for-libr
     =goal>
       state     reason
    =imaginal>
      f-sentence "If_essay_then_library"
      s-sentence =s-sentence
      fact       "library"
      interpretation nil
    ==>
     =imaginal>
      interpretation sufficient
      value "yes"
     =goal>
    !eval! ("add_production_rule" (list =s-sentence "library" "yes" "sufficient"))
)

;; Argument fact with sufficient explanation{fact(library), sufficient explanation(library, textbook)}
(p textbook-sufficient-explanation-for-libr
     =goal>
       state     reason
    =imaginal>
      s-sentence "If_textbook_then_library"
      fact       "library"
      interpretation nil
    ==>
     =imaginal>
      interpretation sufficient
      value "unknown"
     =goal>
    !eval! ("add_production_rule" (list "If_textbook_then_library" "sufficient" "library" "unknown"))
)

;; Argument fact with secondary necessary prediction{fact(library), sec necessary prediction(library, essay)}
(p essay-sec-necessary-for-libr
     =goal>
       state     reason
    =imaginal>
      f-sentence "If_essay_then_library"
      s-sentence =s-sentence
      - s-sentence "If_textbook_then_library"
      fact       "library"
      interpretation nil
    ==>
     =imaginal>
      interpretation necessary
      value "yes"
     =goal>
    !eval! ("add_production_rule" (list =s-sentence "library" "yes" "necessary"))
)

;; Argument fact with secondary necessary prediction{fact(library), sec necessary prediction(library, open)}
#| (p open-sec-necessary-for-libr
     =goal>
       state     reason
    =imaginal>
      s-sentence "If_open_then_library"
      fact       "library"
      interpretation nil
    ==>
     =imaginal>
      interpretation necessary
      value "unknown"
     =goal>
    !eval! ("add_production_rule" (list "If_open_then_library" "library" "unknown" "necessary"))
) |#


;;  Argument with hypothesis and exeogenous explanation {fact(library), exogeneous-explanation(library, exo(library))}
(p exo-explanation-libr
     =goal>
       state     reason
    =imaginal>
      fact       "library"
      s-sentence =s-sentence
      interpretation nil
    ==>
     =imaginal>
      interpretation sufficient
      value "unknown"
     =goal>
    !eval! ("add_production_rule" (list =s-sentence "library" "unknown" "sufficient"))
)


;;;;;;;;;;;;;;;;;;;;;;;; PART II: not Library ;;;;;;;;;;;;;;;;;;;;;;;;

;; Argument fact with necessary explanation {fact(not library), necessary explanation(not library, not essay)}
(p essay-necessary-expl-for-libr
     =goal>
       state     reason
    =imaginal>
      f-sentence "If_essay_then_library"
      s-sentence =s-sentence
      fact       "not_library"
      interpretation nil
    ==>
     =imaginal>
      interpretation necessary
      value "no"
     =goal>
    !eval! ("add_production_rule" (list =s-sentence "not_library" "no" "necessary"))
)

;; Argument fact with necessary explanation {fact(not library), necessary explanation(not library, not open)}
(p open-necessary-expl-for-libr
     =goal>
       state     reason
    =imaginal>
      s-sentence "If_open_then_library"
      s-sentence =s-sentence
      fact       "not_library"
      interpretation nil
    ==>
     =imaginal>
      interpretation necessary
      value "unknown"
     =goal>
    !eval! ("add_production_rule" (list =s-sentence "not_library" "unknown" "necessary"))
)

;; Argument fact with secondary sufficient prediction{fact(not library), sec sufficient prediction(not library, not essay)}
(p essay-sec-sufficient-for-libr
     =goal>
       state     reason
    =imaginal>
      fact       "not_library"
      s-sentence =s-sentence
      interpretation nil
    ==>
     =imaginal>
      interpretation sufficient
      value "no"
     =goal>
    !eval! ("add_production_rule" (list =s-sentence "not_library" "no" "sufficient"))
)

;; Argument fact with secondary sufficient prediction{fact(not library), sec sufficient prediction(not library, not textbook)}
#|(p open-sec-sufficient-for-libr
     =goal>
       state     reason
    =imaginal>
      s-sentence "If_textbook_then_library"
      fact       "not_library"
      interpretation nil
    ==>
     =imaginal>
      interpretation sufficient
      value "unknown"
     =goal>
)|#


;; Preference relations

; Part I: essay
(spp essay-sufficient-for-libr :u 50) ; :at 10
(spp hypo-textbook-sufficient-for-libr :u 50) ; :at 10
(spp hypo-not-open-open-necessary-for-libr :u 50) ; :at 10

; Part I: not_essay
(spp no-essay-necessary-for-libr :u 50)
(spp no-essay-hypo-open-necessary-for-libr :u 49)
(spp hypo-sufficient-for-libr :u 45)

; Part II: library
(spp hypo-essay-sufficient-explanation-for-libr :u 50)
(spp textbook-sufficient-explanation-for-libr :u 52)
(spp essay-sec-necessary-for-libr :u 51)
(spp exo-explanation-libr :u 51)

; Part II: not library
(spp essay-necessary-expl-for-libr :u 50)
(spp open-necessary-expl-for-libr :u 52)
(spp essay-sec-sufficient-for-libr :u 50)


