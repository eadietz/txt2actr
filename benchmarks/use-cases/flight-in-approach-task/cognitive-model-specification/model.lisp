; Dieses Modell kann/macht ...

; Beteiligte Module: Visual, Imaginal, Motor


; Goal-flow

(clear-all)

(define-model exercise_2

(sgp			; Welche notwendig?
:show-focus t
:v nil
:trace-detail low
:time-master-start-increment 1.0
:esc t
;:ans .2
;:bll .5
)	; Detail level of stepper/output

; Chunktypes + Slots

(chunk-type goal state)
(chunk-type interface_value category reference display)



; Declarative memory		| Chunk-name isa chunk-type slot-name slot-value slot-name slot-value
(add-dm



; Speed
(ATC-SPD isa interface_value category SPD reference future)
(IAS isa interface_value category SPD reference current)
(a_bit isa interface_value category time_left reference current)
(a_lot isa interface_value category time_left reference current)


(starting-goal isa goal state start)


(unattended isa chunk)
(idle isa chunk)
(waiting isa chunk)
(memorize isa chunk)
(compare isa chunk)
(done isa chunk)
(done2 isa chunk)
(done3 isa chunk)
(adjusting isa chunk)
(start isa chunk)
(attend isa chunk)
(next isa chunk)
(SPD isa chunk)
(check isa chunk)
(next2 isa chunk)
(scanFCU isa chunk)
(readFCU isa chunk)



)


; Productions


(p	wait-for-start
	=goal>
		state 	start
	?temporal>
		state	free
	==>
	+temporal>
		isa		time
	=goal>
		state	waiting
)


(p start 						; start model
     =goal>
       state     waiting
     =temporal>
		> ticks	1
   ==>
	+temporal>
		isa 	clear
    =goal>
       state     unattended)

; ______________________________________________________________________________
; ATC
; Spez. Ort für ATC SPD scannen (Top-down)
 (p scan-ATC-SPD
      =goal>
       state    unattended
      ?visual-location>
        state     free
      ?visual>
        state     free
    ==>
	+visual-location>
		color 		ATC-SPD
;		>= screen-x	30				; Positionskoordinaten fuer speed (=window + text)
;		<= screen-x	70				; PROBLEM: no detection of area
;		screen-y	206
    +visual>
        clear     t ;; Stop visual buffer from updating without explicit requests
    =goal>
      state    attend
	)

; Aufmerksamkeit ausrichten auf ATC SPD
 (p read-ATC-SPD
	=goal>
		state	attend
	=visual-location>
	?visual>
		state 	free
	==>
	+visual>
		cmd			move-attention
		screen-pos 	=visual-location
	=goal>
		state	memorize
	)

; Save new ATC SPD value in imaginal buffer
(p encode-ATC-SPD
	=goal>
		state 	memorize
	=visual>
      value		=ATC-SPD
	  color		ATC-SPD
    ?imaginal>
	  buffer    empty
;	?retrieval>
;		state	empty
   ==>
    +imaginal>
		ATC-SPD	=ATC-SPD
;	+retrieval>
;		isa		interface_value
;		ATC-SPD	=ATC-SPD
	 =goal>
		state    unattended

)




; ______________________________________________________________________________
; Check if ATC SPD value new?
; If atc SPD value in visual buffer = atc SPD value in retrieval buffer, delete atc value from retrieval buffe

; no new ATC SPD value available
(p mismatch-new-ATC-SPD-value
	=goal>
		state		memorize
	=imaginal>
		ATC-SPD		=ATC-SPD
	=visual>
		value		=ATC-SPD
		color		ATC-SPD
	==>
	=imaginal>
	=goal>
		state 		unattended
	!output! =ATC-SPD
)

; new ATC SPD value available
(p match-new-ATC-SPD-value
	=goal>
		state		memorize
	=visual>
		value		=ATC-SPD
		color		ATC-SPD
	=imaginal>
		- ATC-SPD	=ATC-SPD
;?temporal>					;activation of time bar
;		state		free
	==>
	=imaginal>
		ATC-SPD		=ATC-SPD
;	+temporal>
;		isa			time
;		kind		ATC-SPD
	=goal>
		state 		next
	!output! (New ATC-SPD =ATC-SPD)
)



;______________________________________________________________________________

; IAS

; Spez. Ort für IAS scannen (Top-down)
 (p scan-IAS
      =goal>
       state    next
      ?visual-location>
        state     free
      ?visual>
        state     free
    ==>
     +visual-location>
		color 		IAS
;        >= screen-x	500		; PROBLEM: no detection of area
;		>= screen-x	600		; Positionskoordinaten nicht korrekt! Loc kann nicht gefunden werden
;		screen-y	206
    +visual>
        clear     t ;; Stop visual buffer from updating without explicit requests
    =goal>
      state    done
    )

; Aufmerksamkeit ausrichten auf IAS
 (p read-IAS
	=goal>
		state	done
	=visual-location>
;	?retrieval>
;		state	free
	;?visual>
	;	state 	free
	==>
	+visual>
		cmd	move-attention
		screen-pos =visual-location
;	+retrieval>
;		- ATC-SPD	nil
	=goal>
		state	done2
)



; Speichern von IAS Wert im Imaginal
#|(p encode-IAS
	=goal>
		state 	done2
	=visual>
      value		=IAS
    ?imaginal>
      buffer    empty
   ==>
    +imaginal>
      IAS		=IAS
    =goal>
      state    done3
)|#




; ______________________________________________________________________________

; Match ATC-IAS

; ATC = IAS
(p match-ATC-IAS				; new
	=goal>
		state		done2
	=imaginal>
		ATC-SPD		=ATC-SPD
	=visual>
		value		=ATC-SPD
		color 		IAS
	==>
	-imaginal>
	=goal>
		state 		unattended
)



; ATC =/ IAS
(p mismatch-ATC-IAS				; adapt
	=goal>
		state		done2
	=visual>
		value		=IAS
		color		IAS
	=imaginal>
		- ATC-SPD	=IAS
		ATC-SPD		=ATC-SPD
	?temporal>
		state 		free
	==>
	=imaginal>							; evtl. +imaginal> -> Modellierungskonzept (SA)
		IAS			=IAS
	+temporal>
		isa			time
;		kind		FCU-SPD
	=goal>
		state 		next2
	!output! (set FCU SPD to =ATC-SPD)
)


; ______________________________________________________________________________

; If (p mismatch-ATC-IAS) is fired, set FCU value equal to ATC-SPD
; ->
; P: FCU value can't be changed, part of environment
; WA: Wait (average time for data input, assumption ca. 2s) until new FCU value appears in  FCU

(p set-new-FCU-value
	=goal>
		state	next2
	=imaginal>
		- IAS		nil
;	+temporal>
;		isa 	time
	=temporal>
;		kind	FCU-SPD
		> ticks	2
	==>
	=imaginal>
	+temporal>
		isa		clear
;		kind	FCU-SPD
	=goal>
		state	scanFCU
	!output! (FCU SPD set to ATC-SPD)
)

; ______________________________________________________________________________
; Check input of ATC-SPD in FCU:
; FCU = ATC-SPD?
; comparision type: FCU-SPD (visual), ATC-SPD (imaginal/retrieval?)

; WA: scan + read FCU-SPD


(p scan-FCU-SPD
	=goal>
		state	scanFCU
	?visual-location>
		state	free
	?visual>
		state	free
	==>
	+visual-location>
		color	FCU-SPD
	+visual>
		clear	t
	=goal>
		state 	readFCU
)
(p read-FCU-SPD
	=goal>
		state	readFCU
	=visual-location>
	?visual>
		state 	free
;	?retrieval>
;		buffer	empty
	==>
	+visual>
		cmd			move-attention
		screen-pos 	=visual-location
;	+retrieval>							; add chunk (from dm) with slot "ATC" to retrieval buffer; it should not be empty!
;		- ATC-SPD	nil
;		name	VISUAL-CHUNK0-1
	=goal>
		state	check
)


; ______________________________

; FCU = ATC-SPD
(p match-ATC-FCU
	=goal>
		state	check
	=imaginal>
;		- ATC-SPD	nil 		; not sufficient:
		ATC-SPD	=FCU-SPD
	=visual>
		value	=FCU-SPD
		color	FCU-SPD
	==>
; [further actions?]			 ; TBD
	=imaginal>
	=goal>
		state	workaround			; TBD: Monitor/Update IAS
  	!output! (Setting of FCU-SPD sucessfull)
)


; FCU /= ATC-SPD
(p mismatch-ATC-FCU
	=goal>
		state	check			; To Do: adapt
	=visual>
		value	=FCU-SPD
		color	FCU-SPD
	=imaginal>
		- ATC-SPD	=FCU-SPD
	==>
;	Check options for mismatch: wrong retrieval, ...
	=imaginal>
	=goal>
		state	unattended
	!output! (Setting of FCU SPD is not correct. Please check again.)
)
; ______________________________________________________________________________
; Update 1.0 IAS

; Spez. Ort für IAS scannen (Top-down)
#| (p scan-IAS-update
      =goal>
       state    updateIAS
      ?visual-location>
        state     free
      ?visual>
        state     free
    ==>
     +visual-location>
		color 		IAS
    +visual>
        clear     t ;; Stop visual buffer from updating without explicit requests
    =goal>
      state    readIAS
    )

; Aufmerksamkeit ausrichten auf IAS
 (p read-IAS-update
	=goal>
		state	readIAS
	=visual-location>
	==>
	+visual>
		cmd	move-attention
		screen-pos =visual-location
	=goal>
		state	encodeIAS
)

(p encode-IAS-update
	=goal>
		state 	encodeIAS
	=visual>
      value		=IAS
	  color		IAS
	=imaginal>
   ==>
    =imaginal>
		IAS		=IAS
	 =goal>
		state    checktime1
)

; ______________________________________________________________________________

; Monitor time left to reach ATC-SPD target
; Check passed time since new atc-spd value

(p scan-timebar
	=goal>
		state	checktime1
	?visual-location>
		state	free
	?visual>
		state	free
	==>
	+visual-location>
		color	timer
	+visual>
		clear	t
	=goal>
		state	checktime2
)

(p read-timebar
	=goal>
		state	checktime2
	=visual-location>
	==>
	+visual>
		cmd			move-attention
		screen-pos	=visual-location
	=goal>
		state	memotime
)

(p encode-timebar
	=goal>
		state 	memotime
	=visual>
      value		=timer
	  color		timer
	=imaginal>
   ==>
    =imaginal>
		timer	=timer
	 =goal>
		state    calcSPD
)
|#
; ______________________________________________________________________________

; timer = 0 -> ??



; ______________________________________________________________________________

; Calculation of rest time
; Wenn timer = ..., dann resttime = ...
#|
(p scan-IAS-PRED
	=goal>
		state	calcSPD
	?visual-location>
		state	free
	?visual>
		state	free
	=imaginal>
;		= > timer 0					; normally: timer>0 but current data: timer=0  | TBD
	==>
	=imaginal>
	+visual-location>
		color	IAS-PRED
	+visual>
		clear	t
	=goal>
		state	readIASP
)

(p read-IAS-PRED				; Aufrechterhalten von imaginal?
	=goal>
		state	readIASP
	=visual-location>
	==>
	+visual>
		cmd			move-attention
		screen-pos	=visual-location
	=goal>
		state	encodeIASP
)

(p encode-IAS-PRED
	=goal>
		state 	encodeIASP
	=visual>
      value		=IAS-PRED
	  color		IAS-PRED
	=imaginal>
   ==>
    =imaginal>
		IAS-PRED	=IAS-PRED
	 =goal>
		state    end
)
|#
; ______________________________________________________________________________
; Problem: How to formulate productions for IAS-CALC? -> use multiple productions
; WA: Google Sheets

	; Calculation of IAS-CALC
	; a) start: in t=30s: 	IAS-CALC(t=30s)=IAS+(IAS-PRED *10)			; IAS-CALC is not reel, created
	;			- IAS-PRED: scan, read, encode
	;			-
	; b) in btw: in t=3s:	IAS-CALC(t=3)=IAS+[IAS-(IAS-3s)]



; Easy speed prediction: (new window)
;			- SPD-TE (Speed Trend Evaluation): scan, read, encode




; Action according to speed prediction

; if 0, monitor atc spd


; if 1, [evaluate measurement options]

; ______________________________________________________________________________
; ______________________________________________________________________________

; Goal: Productions to define further actions based on speed trend and time left
; Q: How can calculated values be known by model? (not visual, not cognitive plausible)
	; if visual:
	; 	- scan, read, encode of time_eval and speed_trend
	;	- productions for actions based on time_eval and speed_trend conditions

; Problem: Which productions are neccesary, if Work Around of time left and speed trend are applied?
		;

; ______________________________________________________________________________

; Time_eval

(p scan-time-evaluation
	=goal>
		state	workaround
	?visual-location>
		state	free
	?visual>
		state	free
	==>
	+visual-location>
		color	time-eval
	+visual>
		clear	t
	=goal>
		state	readtime
)

(p read-time-evaluation
	=goal>
		state	readtime
	=visual-location>
	==>
	+visual>
		cmd			move-attention
		screen-pos	=visual-location
	=goal>
		state	encodetime
)

(p encode-time-evaluation
	=goal>
		state 	encodetime
	=visual>
      value		=time-eval
	  color		time-eval
	=imaginal>
   ==>
    =imaginal>
		time-eval	=time-eval
	 =goal>
		state    workaroundfollow
)

; ______________________________________________________________________________
; speed_trend

(p scan-speed-trend
	=goal>
		state	workaroundfollow
	?visual-location>
		state	free
	?visual>
		state	free
	==>
	+visual-location>
		color	SPD-eval
	+visual>
		clear	t
	=goal>
		state	readspeedtrend
)

(p read-speed-trend
	=goal>
		state	readspeedtrend
	=visual-location>
	==>
	+visual>
		cmd			move-attention
		screen-pos	=visual-location
	=goal>
		state	encodespeedtrend
)

(p encode-speed-trend
	=goal>
		state 	encodespeedtrend
	=visual>
      value		=SPD-eval
	  color		SPD-eval
	=imaginal>
   ==>
    =imaginal>
		SPD-eval	=SPD-eval
	=goal>
		state    end
)


; ______________________________________________________________________________
; Decision matrix

; Problem: How to adress specific values of variables? @Emma

(p action-needed-1
	=goal>
		state	end
	=imaginal>
		time-eval	=time-eval	; a bit | a lot
		SPD-eval	=SPD-eval	; increasing
	==>
	=imaginal>
;	[Define action to be peformed: Speed brakes | spoiler | LDG]
	=goal>
		state	theend
)


(p action-needed-2
	=goal>
		state	end
	=imaginal>
		time-eval	a_bit			; a bit
		SPD-eval	low_decrease	; low | medium decrease
	==>
	=imaginal>
;	[Define action to be peformed: Speed brakes | spoiler | LDG]
	=goal>
		state	startaction
)



(p action-not-needed
	=goal>
		state	end
	=imaginal>
		time-eval	a_bit	; a bit | a lot
		SPD-eval	high_decrease	; high_decrease
	==>
	=imaginal>
;	[Define action to be peformed: no action needed]
	=goal>
		state	theend2
)

; ______________________________________________________________________________

; Landing Gear
	; Check gear position

	(p scan-LDG-position
		=goal>
			state	startaction
		?visual-location>
			state	free
		?visual>
			state	free
		==>
		+visual-location>
			color	LDG-POS
		+visual>
			clear	t
		=goal>
			state	readLDGpos)


	(p read-LDG-position
		=goal>
			state	readLDGpos
		=visual-location>
		==>
		+visual>
			cmd			move-attention
			screen-pos	=visual-location
		=goal>
			state	encodeLDGpos)


	(p encode-LDG-position
		=goal>
			state 	encodeLDGpos
		=visual>
			value		=LDG-POS
			color		LDG-POS
		=imaginal>
		==>
		=imaginal>
			LDG-POS		=LDG-POS
		=goal>
			state    checkLDGcon)



	; Check gear condition: Can be put down? (If IAS < 250)

	(p check-LDG-condition
		=goal>
			state	checkLDGcon
		=imaginal>
			< IAS	250
		==>
		=imaginal>
		+temporal>
			isa 	time
		=goal>
			state	setLDG
	)

	; Set LDG: down

	(p set-LDG
		=goal>
			state	setLDG
		=temporal>
			> ticks	2
		==>
		+temporal>
			isa 	clear
		=goal>
			state	wait
		!output! (LDG set to down)
	)


; Flaps (depending on IAS)


; V/S


; Spoiler















; ______________________________________________________________________________
; ______________________________________________________________________________
; Goal
(goal-focus starting-goal)
	)


(record-history "buffer-trace" "goal" "visual")