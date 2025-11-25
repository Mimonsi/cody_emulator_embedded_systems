8  REM Page 310/311
9  REM 50176/$C400 = default screen memory start
10 FOR I=0 TO 999
20 POKE 50176+I,97+MOD(I,26)
30 NEXT

