5  REM Page 318-320
6  REM 55296/$D800 = default color memory start
7  REM 51200/$C800 = default char memory start
8  REM 50176/$C400 = default screen memory start
9  REM 53253/$D005 = screen color register
10 FOR I=0 TO 7
20 READ M
30 POKE 51200+255*8+I,M
40 NEXT
50 FOR I=0 TO 999
60 POKE 50176+I,255
70 POKE 55296+I,MOD(RND(),16)*16+MOD(RND(),16)
80 NEXT
90 POKE 53253,1
100 DATA 80,80,80,80,250,250,250,250

