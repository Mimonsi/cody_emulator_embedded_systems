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

STRPTR    = $D0                 ; Pointer to string (2 bytes)
SCRPTR    = $D2                 ; Pointer to screen (2 bytes)

KEYROW0   = $DA                 ; Keyboard row 0
KEYROW1   = $DB                 ; Keyboard row 1
KEYROW2   = $DC                 ; Keyboard row 2
KEYROW3   = $DD                 ; Keyboard row 3
KEYROW4   = $DE                 ; Keyboard row 4
KEYROW5   = $DF                 ; Keyboard row 5

PRGLEN    = $D8                 ; Length of the program in memory

; Program header for Cody Basic's loader (needs to be first)

.WORD ADDR                      ; Starting address (just like KIM-1, Commodore, etc.)
.WORD (ADDR + LAST - MAIN - 1)  ; Ending address (so we know when we're done loading)

;
; The actual program.
;

.LOGICAL    ADDR                ; The actual program gets loaded at ADDR

            
;_LOOP       LDA TEXT,X          ; Copies TEXT into screen memory (kept for reference)
;            BEQ _DONE
;            
;            STA SCRRAM,X
;            
;            INX
;            BRA _LOOP

MAIN        STZ PRGLEN          ; Clear program length
            STZ PRGLEN+1
            
            JSR SHOWSCRN
            
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
            
_QUIT       RTS                 ; Return to BASIC
            
_LOAD       
            BRA _LOOP
            
_PROG       
            BRA _LOOP


;
; SHOWSCRN
;
; Shows the main screen.
;
SHOWSCRN  JSR CLRSCRN
            
          LDX #0
          LDY #0
          JSR MOVESCRN
          
          LDX #MSG_TICTACTOE
          JSR PUTMSG
          
          LDX #0
          LDY #1
          JSR MOVESCRN
          
          LDX #MSG_SUBTITLE
          JSR PUTMSG

          LDX #0
          LDY #3
          JSR MOVESCRN
          
          LDX #MSG_MENUINSTRUCTIONS
          JSR PUTMSG

          LDX #0
          LDY #4
          JSR MOVESCRN
          
          LDX #MSG_MENUPLAY
          JSR PUTMSG
          
          LDX #0
          LDY #5
          JSR MOVESCRN
          
          LDX #MSG_MENUQUIT
          JSR PUTMSG
          
          RTS

;
; KEYSCAN
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


;
; MOVESCRN
;
; Moves the SCRPTR to the position for the column/row in the X and Y
; registers. All registers are clobbered by the routine.
;
MOVESCRN  LDA #<SCRRAM            ; Move screen pointer to beginning
          STA SCRPTR+0
          LDA #>SCRRAM
          STA SCRPTR+1
          
          INY                     ; Increment pointer for each row
_LOOPY    CLC 
          LDA SCRPTR+0
          ADC #40
          STA SCRPTR+0
          LDA SCRPTR+1
          ADC #0
          STA SCRPTR+1
          DEY
          BNE _LOOPY
          
          CLC                     ; Add position on column
          TXA
          ADC SCRPTR+0
          STA SCRPTR+0
          LDA SCRPTR+1
          ADC #0
          STA SCRPTR+1
          
          RTS

;
; CLRSCRN
;
; Clear the entire screen by filling it with whitespace (ASCII 20 decimal).
;
CLRSCRN   LDA #<SCRRAM            ; Move screen pointer to beginning
          STA SCRPTR+0
          LDA #>SCRRAM
          STA SCRPTR+1
          
          LDA #20                 ; Clear screen by filling with whitespaces
          
          LDY #25                 ; Loop 25 times on Y
          
_LOOPY    LDX #40                 ; Loop 40 times on X for each Y
          
_LOOPX    STA (SCRPTR)            ; Store zero

          INC SCRPTR+0            ; Increment screen position
          BNE _NEXT
          INC SCRPTR+1
          
_NEXT     DEX                     ; Next X
          BNE _LOOPX
          
          DEY                     ; Next Y
          BNE _LOOPY
          
          RTS


;
; PUTMSG
;
; Puts a message string (one of the MSG_XXX constants) on the screen.
;
PUTMSG      PHA
            PHY
            
            LDA MSGS_L,X        ; Load the pointer for the string to print
            STA STRPTR+0
            LDA MSGS_H,X
            STA STRPTR+1
            
            LDY #0
            
_LOOP       LDA (STRPTR),Y      ; Read the next character (check for null)
            BEQ _DONE
            
            JSR PUTCHR          ; Copy the character and move to next
            INY         
            
            BRA _LOOP           ; Next loop
            
_DONE       PLY
            PLA
            
            RTS

;
; PUTCHR
;
; Puts an individual ASCII character on the screen.
;
PUTCHR      STA (SCRPTR)        ; Copy the character   
            
            INC SCRPTR+0        ; Increment screen position
            BNE _DONE
            INC SCRPTR+1
          
_DONE       RTS

;
; IDs for the message strings that can be displayed in the program.
;
MSG_TICTACTOE  = 0
MSG_SUBTITLE  = 1
MSG_MENUINSTRUCTIONS = 2
MSG_MENUPLAY  = 3
MSG_MENUQUIT  = 4
MSG_WAITBINA  = 5
MSG_WAITREPE  = 6
MSG_RECVDATA  = 7
MSG_PROGDATA  = 8
MSG_VERIDATA  = 9
MSG_VERIFYOK  = 10
MSG_VERIFYBAD = 11
MSG_LENGTH    = 12
MSG_CLEAR     = 13
MSG_ERROR     = 14

;
; The strings displayed by the program.
;
STR_TICTACTOE  .NULL "Tic Tac Toe"
STR_SUBTITLE  .NULL "Welcome to Tic Tac Toe!"
STR_MENUINSTRUCTIONS .NULL "Press Q-O keys to select position."
STR_MENUPLAY  .NULL "(P)lay"
STR_MENUQUIT  .NULL "(Q)uit"
STR_WAITBINA  .NULL "Waiting for binary data..."
STR_WAITREPE  .NULL "Waiting for repeat data to verify..."
STR_RECVDATA  .NULL "Receiving data..."
STR_PROGDATA  .NULL "Programming data..."
STR_VERIDATA  .NULL "Verifying data..."
STR_VERIFYOK  .NULL "Verify OK."
STR_VERIFYBAD .NULL "Verify FAILED."
STR_LENGTH    .NULL "Length: $"
STR_CLEAR     .NULL "                                    "
STR_ERROR     .NULL "ERROR"

;
; Low bytes of the string table addresses.
;
MSGS_L
  .BYTE <STR_TICTACTOE
  .BYTE <STR_SUBTITLE
  .BYTE <STR_MENUINSTRUCTIONS
  .BYTE <STR_MENUPLAY
  .BYTE <STR_MENUQUIT
  .BYTE <STR_WAITBINA
  .BYTE <STR_WAITREPE
  .BYTE <STR_RECVDATA
  .BYTE <STR_PROGDATA
  .BYTE <STR_VERIDATA
  .BYTE <STR_VERIFYOK
  .BYTE <STR_VERIFYBAD
  .BYTE <STR_LENGTH
  .BYTE <STR_CLEAR
  .BYTE <STR_ERROR

;
; High bytes of the string table addresses.
;
MSGS_H
  .BYTE >STR_TICTACTOE
  .BYTE >STR_SUBTITLE
  .BYTE >STR_MENUINSTRUCTIONS
  .BYTE >STR_MENUPLAY
  .BYTE >STR_MENUQUIT
  .BYTE >STR_WAITBINA
  .BYTE >STR_WAITREPE
  .BYTE >STR_RECVDATA
  .BYTE >STR_PROGDATA
  .BYTE >STR_VERIDATA
  .BYTE >STR_VERIFYOK
  .BYTE >STR_VERIFYBAD
  .BYTE >STR_LENGTH
  .BYTE >STR_CLEAR
  .BYTE >STR_ERROR

LAST                            ; End of the entire program

.ENDLOGICAL
