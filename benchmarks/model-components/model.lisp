(clear-all)
(define-model dummy-model
 (sgp
   :ppm 40
   :auto-attend nil
   :esc t
   :v t
   :show-focus t
   :time-master-start-increment 0.01 ; not cognitively plausible
   :time-mult 0.1 ; not cognitively plausible
   :time-noise 0.001 ; not cognitively plausible
   :trace-detail high
   :ul t
   ;:tone-detect-delay 1.0
   ;:ans .5
   ;:mp 10
   )
(add-word-characters ".")
(add-word-characters "_")
)