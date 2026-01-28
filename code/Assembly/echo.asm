
ADDR    = $3000                 ; The actual loading address of the program
SCRRAM  = $C400                 ; The default location of screen memory

; Program header for Cody Basic's loader (needs to be first)

.WORD ADDR                      ; Starting address (just like KIM-1, Commodore, etc.)
.WORD (ADDR + LAST - MAIN - 1)  ; Ending address (so we know when we're done loading)

;
; The actual program.
;

.LOGICAL    ADDR                ; The actual program gets loaded at ADDR

MAIN        LDX #0              ; The program starts running from here
            
;_LOOP       LDA TEXT,X          ; Copies TEXT into screen memory
;            BEQ _DONE
;            
;            STA SCRRAM,X
;            
;            INX
;            BRA _LOOP


_LOOP       JSR KEYSCAN         ; Scan the keyboard

            LDA KEYROW0         ; Pressed Q for quit?
            AND #%00001
            BNE _QUIT
            
            LDA KEYROW1         ; Pressed L for load?
            AND #%10000
            BNE _LOAD
            
            LDA KEYROW5         ; Pressed P for program?
            AND #%10000
            BNE _PROG
            
            BRA _LOOP           ; Repeat main loop
            
_DONE       JMP _DONE           ; Loops forever
            
TEXT        .NULL "Cody!"       ; TEXT as a null-terminated string

LAST                            ; End of the entire program

.ENDLOGICAL
