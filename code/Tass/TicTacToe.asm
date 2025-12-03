; Konstantin Schwarze 2025
; Tic Tac Toe for Cody Computer

; Controls: Use keys Q-O to select positions 1-9
; |1|2|3|    | | | |
; |4|5|6| -> | |X| | -> ...
; |7|8|9|    | | | |
; Player x goes first, o goes second
; 64tass --mw65c02 --nostart -o TicTacToe.bin TicTacToe.asm

ADDR    = $3000                 ; The actual loading address of the program
SCRRAM  = $C400                 ; The default location of screen memory

VIA_BASE  = $9F00               ; VIA base address and register locations
VIA_IORB  = VIA_BASE+$0
VIA_IORA  = VIA_BASE+$1
VIA_DDRB  = VIA_BASE+$2
VIA_DDRA  = VIA_BASE+$3
VIA_T1CL  = VIA_BASE+$4
VIA_T1CH  = VIA_BASE+$5
VIA_SR    = VIA_BASE+$A
VIA_ACR   = VIA_BASE+$B
VIA_PCR   = VIA_BASE+$C
VIA_IFR   = VIA_BASE+$D

KEYROW0   = $DA                 ; Keyboard row 0
KEYROW1   = $DB                 ; Keyboard row 1
KEYROW2   = $DC                 ; Keyboard row 2
KEYROW3   = $DD                 ; Keyboard row 3
KEYROW4   = $DE                 ; Keyboard row 4
KEYROW5   = $DF                 ; Keyboard row 5

; Program header for Cody Basic's loader (needs to be first)

.WORD ADDR                      ; Starting address (just like KIM-1, Commodore, etc.)
.WORD (ADDR + LAST - MAIN - 1)  ; Ending address (so we know when we're done loading)

;
; The actual program.
;

.LOGICAL    ADDR                ; The actual program gets loaded at ADDR

MAIN        LDX #0              ; The program starts running from here

            
;_LOOP       LDA TEXT,X          ; Copies TEXT into screen memory (kept for reference)
;            BEQ _DONE
;            
;            STA SCRRAM,X
;            
;            INX
;            BRA _LOOP


_LOOP       LDA INTRO_TEXT,X         ; Display intro text
            JSR KEYSCAN         ; Scan the keyboard

            LDA KEYROW0         ; Pressed Q for 1
            AND #%00001
            BNE _K1
            
            LDA KEYROW0         ; Pressed W for 2
            AND #%10000
            BNE _K2
            
            LDA KEYROW0         ; Pressed E for 3
            AND #%10000
            BNE _K3
            
            BRA _LOOP           ; Repeat main loop
    
_K1         LDA #$31           ; ASCII '1'
            STA SCRRAM + 0      ; Place '1' at position 1
            BRA _LOOP           ; Repeat main loop

_K2         LDA #$32           ; ASCII '2'
            STA SCRRAM + 1      ; Place '2' at position 2
            BRA _LOOP           ; Repeat main loop

_K3         LDA #$33           ; ASCII '3'
            STA SCRRAM + 2      ; Place '3' at position 3
            BRA _LOOP           ; Repeat main loop
            
_DONE       JMP _DONE           ; Loops forever

; KEYSCAN (taken from codyprog.asm)
;
; Scans the keyboard matrix (so that key selections for menu options can be detected).
;
KEYSCAN     PHA                   ; Preserve registers
            PHX
            
            STZ VIA_IORA          ; Start at the first row and first key of the keyboard
            LDX #0
            
_LOOP       LDA VIA_IORA          ; Read the keys for the current row from the VIA port
            EOR #$FF
            LSR A
            LSR A
            LSR A
            STA KEYROW0,X
            
            INC VIA_IORA          ; Move on to the next keyboard row
            INX
            
            CPX #6                ; Do we have any rows remaining to scan?
            BNE _LOOP
            
            PLX                   ; Restore registers
            PLA
            
            RTS
            
INTRO_TEXT        .NULL "Welcome to Tic Tac Toe!"       ; TEXT as a null-terminated string

LAST                            ; End of the entire program

.ENDLOGICAL
