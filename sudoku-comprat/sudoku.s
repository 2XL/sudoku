@;=== Programa per a calcular possibles n�meros en una casella d'un sudoku ===
@;= alumne 1 = laura.fontanet@estudiants.urv.cat
@;= alumne 2 = fermin.rodriguez@estudiants.urv.cat

@;--- .data. Non-zero Initialized data ---
.data
	.global sudoku_input @;matriu d'entrada (9 files x 9 columnes,
  sudoku_input: @; m�s 7 columnes a -1 per motius de visualitzaci� en debugger)
	.byte 0, 1, 2, 0, 0, 9, 0, 0, 6, -1, -1, -1, -1, -1, -1, -1
	.byte 5, 0, 0, 0, 3, 0, 0, 2, 0, -1, -1, -1, -1, -1, -1, -1
	.byte 0, 9, 8, 0, 0, 0, 0, 0, 7, -1, -1, -1, -1, -1, -1, -1
	.byte 0, 2, 3, 7, 0, 4, 6, 0, 0, -1, -1, -1, -1, -1, -1, -1
	.byte 0, 8, 5, 0, 1, 0, 4, 7, 0, -1, -1, -1, -1, -1, -1, -1
	.byte 0, 0, 4, 6, 0, 5, 1, 8, 0, -1, -1, -1, -1, -1, -1, -1
	.byte 2, 0, 0, 0, 0, 0, 8, 5, 0, -1, -1, -1, -1, -1, -1, -1
	.byte 0, 6, 0, 0, 7, 0, 0, 0, 1, -1, -1, -1, -1, -1, -1, -1
	.byte 8, 0, 0, 3, 0, 0, 7, 6, 0, -1, -1, -1, -1, -1, -1, -1
								@;fila de separaci� amb la matriu de sortida
	.byte -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1

@;-- .bss. Zero initialized data ---
.bss
	.global sudoku_output    @;matriu de sortida (82 files x 12 columnes,
  sudoku_output:         @; m�s 4 columnes a -2 per motius de visualitzacio en debugger)
	.space 82*16     @;format de sortida, per cada fila:
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
	@;- resultat:
	@;- R4 = adre�a base de la matriu de resultats
	@;- R5 = n�mero de files de la matriu de resultats
	principal:
		push {r0-r3,r6,r7, lr} @;salva a la pila els registres a modificar
		
		ldr r0, =sudoku_input @;carrega adre�a matriu de sudoku en R0
		ldr r4, =sudoku_output @;carrega adre�a matriu de resultats en R4
		mov r5, #0 @;R5 = �ndex de fila de resultats
		mov r1, #0 @;R1 = �ndex de fila de sudoku
	.Lbuc_fil: @;bucle per a rec�rrer totes les files del sudoku
		mov r2, #0 @;R2 = �ndex de columna
	.Lbuc_col: @;bucle per a rec�rrer totes les columnes del sudoku
		add r6, r2, r1, lsl #4 @;R6 = offset (fila * 16) + columna
		ldrb r7, [r0, r6] @;carrega l'element (fila,columna) en R7
		cmp r7, #0 @;detecta si es tracta d'una posici� buida
		bne .Lcont1 @;en cas negatiu, salta el paquet d'instruccions seguent
		add r3, r4, r5, lsl #4 @;R3 = adre�a fila resultats
		bl fila_result @;calcula fila resultats
		add r5, #1 @;incrementa �ndex fila resultats
	.Lcont1:
		add r2, #1 @;passa a la seg�ent columna matriu sudoku
		cmp r2, #9 @;verifica si ha arribat a l'�ltima columna
		bne .Lbuc_col @;en cas negatiu, continua el bucle de columnes
		add r1, #1 @;passa a la seg�ent fila matriu sudoku
		cmp r1, #9 @;verifica si ha arribat a l'�ltima fila
		bne .Lbuc_fil @;en cas negatiu, continua el bucle de files
		pop {r0-r3,r6,r7, pc} @;restaura registres i retorna de la rutina




	@;- Funci� 'fila_result' -> calcula els n�meros que poden anar en una casella del sudoku;
	@;- par�metres:
	@;- R0 : adre�a base matriu sudoku
	@;- R1 : fila de la casella
	@;- R2 : columna de la casella
	@;- R3 : adre�a base de la fila de resultats (veure descipci� en secci� .bss)
	fila_result:
			push {r4, r5, r6, r7, r8, r9, lr} @;guarda en la pila los registros que vamos a utilizar
			
		@;inicializamos el vector "fila_resultats"
		bl llenarvector
		
		add r3, #2 @;desplazamos el indice a la posici�n del contador de resultados
		@;tenemos guardados la fila y la columna de la casilla que estamos analizando
		@;utilizaremos el registro R2 como indice para el bucle que recorre filas 
		
		mov r10, r2 @; Guardamos r2 en r10, para no perder el valor, hacemos copia 
		mov r2,#0 
	.recorreFilas:
		ldrb r4, [r3] @;cargamos el valor de posibles resultados en r4
		@; para esta funci�n tenemos:
		@; el registro que marca la fila - R1
		@; el registro que marca la columna - R2
		@; direcci�n de la fila de resultados con un desplazamiento de 2 - R3
		@; el contador de posibles resultados - r4
		bl actual_result
		strb r4, [r3]  @; Despu�s de pasar por la funci�n "actual_result", guardamos el valor del
		@; contador "r4" en r3
		add r2, r2, #1
		cmp r2, #9
		bne .recorreFilas
		mov r2, r10 @; recuperamos el valor de R2
		mov r10, r1 @; igual que con r2, guardamos el valor de r1 en r10 
		mov r1,#0 
	.recorreColumnas:
		ldrb r4, [r3] 
		bl actual_result
		strb r4, [r3] 
		add r1, r1, #1
		cmp r1, #9
		bne .recorreColumnas 
		mov r1, r10 @; Recuperamos r1
		@;tenemos otra vez la fila en r1 y la columna en r2
		@;llamamos a la funci�n "subquad_result"
		bl subquad_result
			pop {r4, r5, r6, r7, r8, r9, pc} 




	@;- Funci� 'actual_result' -> tanca el n�mero que troba a la casella [R1,R2] dins la posicio corresponent de resultats (escriu un 0)
	@;- par�metres:
	@;- R0 : adre�a base matriu sudoku
	@;- R1 : fila de la casella
	@;- R2 : columna de la casella
	@;- R3 : adre�a de la fila de resultats, despla�ada fins a comptador de possibles resultats (offset 2)
	@;- R4 : comptador de possibles resultats (entrada)
	@;- resultats:
	@;- R4 : comptador de possibles resultats (sortida)
	actual_result:
			push {r5, r6, r7, r8, lr} 
			
		add r5, r2, r1, lsl #4 
		ldrb r5, [r0, r5] @; en r5 cargamos el contenido de la casilla de la matriz sudoku 
		cmp r5, #0 @; comparamos ese valor con 0, en caso positivo se acabaria la funci�n 
		beq .fi_funcio 
		ldrb r6, [r3, r5] @; al no ser 0, cargamos el contenido de la celda correspondiente del vector fila_result
		cmp r6, #0 @; si ese contenido es 0, la funci�n terminaria
		beq .fi_funcio 
		mov r9, #0 
		strb r9, [r3, r5] @; colocamos un 0 en esa posici�n
		sub r4, #1 @; restamos 1 al contador de resultados
	.fi_funcio:
			
			pop {r5, r6, r7, r8, pc} 



	@;- Funci� 'subquad_result' -> calcula els n�meros que poden anar a una casella en un subquadrat del sudoku;
	@;- par�metres:
	@;- R0 : adre�a base matriu sudoku
	@;- R1 : fila de la casella
	@;- R2 : columna de la casella
	@;- R3 : adre�a de la fila de resultats, despla�ada fins a comptador de possibles resultats (offset 2)
	@;- R4 : comptador de possibles resultats (entrada)
	@;- resultats:
	@;- R4 : comptador de possibles resultats (sortida)
	subquad_result:
			push {lr} 
			
		mov r5, r1 @;guardamos r1 en r5 para que no cambie el valor
		bl divmul_3 @;llamamos a la funcion 
		mov r10, r1 @; guardamos el nuevo r1 en r10 para conservarlo
		mov r1, r5 @; recuperamos el antiguo r1
		mov r5, r2 @; hacemos lo mismo que antes pero con r2
		bl divmul_3 
		mov r11, r2
		mov r2, r5
		add r6, r1, #3 @; usamos r6 como fila final del cuadrado
		add r7, r2, #3 @; igual que antes pero con las columnas
		@;utilizamos un doble bucle similar al de la primera funci�n para recorrer el cuadrado
		@;tenemos guardados r1 y r2 as� que los utilizaremos 
		@;en este momento r2 es igual a r5
	.recorrer_fila_subquad:
		mov r2, r5 @; esta funcion aumentar� la posici�n de la fila en cada pasada
	.recorrer_columna_subquad:
		ldrb r4, [r3] 
		bl actual_result @; llamamos a la funcion actual_result para descartar los numeros que encontramos
		strb r4, [r3] 
		add r2, #1
		cmp r2, r7
		bne .recorrer_columna_subquad @; esta comparaci�n es para saber si hemos llegado al final del cuadrado
		add r1, #1
		cmp r1, r6
		bne .recorrer_fila_subquad @; en caso de no llegar a la ultima fila, volvemos a empezar el bucle.
		mov r2, r11
		mov r1, r10
			
			pop {pc} 



	@;- Funci� 'divmul_3' -> calcula la fila/columna base d'una subregi�, a partir d'un �ndex de
	@;- fila o columna (0-8), obtenint un n�mero m�ltiple de 3 (0, 3, 6)
	@;- par�metres:
	@;- R5 : �ndex d'entrada (0-8)
	@;- resultats:
	@;- R5 : n�mero base de sortida (0, 3, 6)
	divmul_3:
			push {lr} 
			
		cmp r5, #2 @; comparamos el valor entrante con 2, si es mayor quiere 
		bhi .segon_subquad @; decir que esta en los siguientes cuadrantes
		mov r5, #0 @; si es m�s peque�o, quiere decir que est� en el primer cuadrante.
		b .final 
	.segon_subquad:
		cmp r5, #5
		bhi .tercer_subquad @; igual que antes, comparamos con 5, si es superior estar� en el tercer cuadrante
		mov r5, #3 @; si es menor, estar� en el segundo cuadrante.
		b .final 
	.tercer_subquad:
		mov r5, #6 
	.final: 
			
			pop {pc} 



llenarvector: @; Con esta funci�n inicializamos el vector "fila_resultats"
			push {lr}
			
		strb r1, [r3,#0] 
		strb r2, [r3,#1] 
		mov r9, #9
		strb r9, [r3,#2] 
		mov r9, #1
		strb r9, [r3,#3] 
		add r9, #1
		strb r9, [r3,#4]
		add r9, #1
		strb r9, [r3,#5]
		add r9, #1
		strb r9, [r3,#6]
		add r9, #1
		strb r9, [r3,#7]
		add r9, #1
		strb r9, [r3,#8]
		add r9, #1
		strb r9, [r3,#9]
		add r9, #1
		strb r9, [r3,#10]
		add r9, #1
		strb r9, [r3,#11] 
		mov r9, #-2 
		strb r9, [r3,#12] 
		strb r9, [r3,#13]
		strb r9, [r3,#14]
		strb r9, [r3,#15]
			
			pop {pc}


.end