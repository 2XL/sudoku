@;=== Programa per a calcular possibles n�meros en una casella d'un sudoku  ===
@;= alumne 1 = nom1.cognom1x@estudiants.urv.cat
@;= alumne 2 = nom2.cognom2x@estudiants.urv.cat

@;--- .data. Non-zero Initialized data ---
.data
		.global sudoku_input		@;matriu d'entrada (9 files x 9 columnes,
	sudoku_input:					@; m�s 7 columnes a -1 per motius de visualitzaci� en debugger)
		.byte	0, 1, 2, 0, 0, 9, 0, 0, 6, -1, -1, -1, -1, -1, -1, -1
		.byte	5, 0, 0, 0, 3, 0, 0, 2, 0, -1, -1, -1, -1, -1, -1, -1
		.byte	0, 9, 8, 0, 0, 0, 0, 0, 7, -1, -1, -1, -1, -1, -1, -1
		.byte	0, 2, 3, 7, 0, 4, 6, 0, 0, -1, -1, -1, -1, -1, -1, -1
		.byte	0, 8, 5, 0, 1, 0, 4, 7, 0, -1, -1, -1, -1, -1, -1, -1
		.byte	0, 0, 4, 6, 0, 5, 1, 8, 0, -1, -1, -1, -1, -1, -1, -1
		.byte	2, 0, 0, 0, 0, 0, 8, 5, 0, -1, -1, -1, -1, -1, -1, -1
		.byte	0, 6, 0, 0, 7, 0, 0, 0, 1, -1, -1, -1, -1, -1, -1, -1
		.byte	8, 0, 0, 3, 0, 0, 7, 6, 0, -1, -1, -1, -1, -1, -1, -1
									@;fila de separaci� amb la matriu de sortida
		.byte	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1

@;-- .bss. Zero initialized data ---
.bss
		.global sudoku_output		@;matriu de sortida (82 files x 12 columnes,
	sudoku_output:					@; m�s 4 columnes a -2 per motius de visualitzacio en debugger)
		.space	82*16				@;format de sortida, per cada fila:
									@; p_fil, p_col, num_pos_sol, poss_1, poss_2, poss_3, ..., poss_9
									@; = p_fil �s posici� fila (de 0 a 8, 0 primera fila)
									@; = p_col �s posici� columna (de 0 a 8, 0 m�s a l'esquerra)
									@; = num_pos_sol �s n�mero de possibles solucions (de 1 a 9)
									@; = poss_1 �s 1 si el 1 �s possible, 0 si no ho �s
									@; = poss_2 �s 2 si el 2 �s possible, 0 si no ho �s
									@; = poss_3 �s 3 si el 3 �s possible, 0 si no ho �s
									@; etc. fins a poss_9
									@; (es completa la taula amb 4 posicions a -2, per fer 16 columnes)


@;-- .text. Program code ---
.text		
		.arm
		.global principal
	@;- Funci� 'principal' -> recorre totes les casella del sudoku i invoca la funci� 'fila_result'
	@;- per detectar quins n�meros poden anar en aquella casella, emmagatzemant el resultat en una
	@;- fila de la matriu de resultats (veure definici� de sudoku_output)
	@;-	resultat:
	@;- R4 = adre�a base de la matriu de resultats
	@;- R5 = n�mero de files de la matriu de resultats
	principal:
			push {r0-r3,r6,r7, lr}	@;salva a la pila els registres a modificar
			
			ldr r0, =sudoku_input	@;carrega adre�a matriu de sudoku en R0
			ldr r4, =sudoku_output	@;carrega adre�a matriu de resultats en R4
			mov r5, #0				@;R5 = �ndex de fila de resultats
			mov r1, #0				@;R1 = �ndex de fila de sudoku
		.Lbuc_fil:					@;bucle per a rec�rrer totes les files del sudoku
			
			mov r2, #0				@;R2 = �ndex de columna
		.Lbuc_col:					@;bucle per a rec�rrer totes les columnes del sudoku
			add r6, r2, r1, lsl #4	@;R6 = offset (fila * 16) + columna
			ldrb r7, [r0, r6]		@;carrega l'element (fila,columna) en R7
			cmp r7, #0				@;detecta si es tracta d'una posici� buida
			bne .Lcont1				@;en cas negatiu, salta el paquet d'instruccions seguent
			add r3, r4, r5, lsl #4	@;R3 = adre�a fila resultats
			bl fila_result			@;calcula fila resultats
			add r5, #1				@;incrementa �ndex fila resultats
		.Lcont1:
			add r2, #1				@;passa a la seg�ent columna matriu sudoku
			cmp r2, #9				@;verifica si ha arribat a l'�ltima columna
			bne .Lbuc_col			@;en cas negatiu, continua el bucle de columnes
			
			add r1, #1				@;passa a la seg�ent fila matriu sudoku
			cmp r1, #9				@;verifica si ha arribat a l'�ltima fila
			bne .Lbuc_fil			@;en cas negatiu, continua el bucle de files
			
			pop {r0-r3,r6,r7, pc}	@;restaura registres i retorna de la rutina




	@;- Funci� 'fila_result' -> calcula els n�meros que poden anar en una casella del sudoku;
	@;-	par�metres:
	@;- R0 : adre�a base matriu sudoku
	@;- R1 : fila de la casella
	@;- R2 : columna de la casella
	@;- R3 : adre�a base de la fila de resultats (veure descipci� en secci� .bss)
	fila_result:
			push {r8-r12, lr}		@;salva a la pila els registres a modificar
			
			
			
			
			
			
			
			
			pop {r8-r12, pc}			@;restaura registres i retorna de la rutina




	@;- Funci� 'actual_result' -> tanca el n�mero que troba a la casella [R1,R2] dins la posicio corresponent de resultats (escriu un 0)
	@;-	par�metres:
	@;- R0 : adre�a base matriu sudoku
	@;- R1 : fila de la casella
	@;- R2 : columna de la casella
	@;- R3 : adre�a de la fila de resultats, despla�ada fins a comptador de possibles resultats (offset 2)
	@;- R4 : comptador de possibles resultats (entrada)
	@;-	resultats:
	@;- R4 : comptador de possibles resultats (sortida)
	actual_result:
			push {lr}		@;salva a la pila els registres a modificar
			
			
			pop {pc}			@;restaura registres i retorna de la rutina



	@;- Funci� 'subquad_result' -> calcula els n�meros que poden anar a una casella en un subquadrat del sudoku;
	@;-	par�metres:
	@;- R0 : adre�a base matriu sudoku
	@;- R1 : fila de la casella
	@;- R2 : columna de la casella
	@;- R3 : adre�a de la fila de resultats, despla�ada fins a comptador de possibles resultats (offset 2)
	@;- R4 : comptador de possibles resultats (entrada)
	@;-	resultats:
	@;- R4 : comptador de possibles resultats (sortida)
	subquad_result:
			push {lr}		@;salva a la pila els registres a modificar
			
			
			pop {pc}			@;restaura registres i retorna de la rutina



	@;- Funci� 'divmul_3' -> calcula la fila/columna base d'una subregi�, a partir d'un �ndex de
	@;- fila o columna (0-8), obtenint un n�mero m�ltiple de 3 (0, 3, 6)
	@;-	par�metres:
	@;- R5 : �ndex d'entrada (0-8)
	@;-	resultats:
	@;- R5 : n�mero base de sortida (0, 3, 6)
	divmul_3:
			push {lr}		@;salva a la pila els registres a modificar
			
			
			pop {pc}			@;restaura registres i retorna de la rutina


.end
