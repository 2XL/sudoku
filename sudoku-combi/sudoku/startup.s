@;=== startup function for ARM assembly programs ===

.text
		.arm
		.global _start
	_start:
			bl principal			@;executa rutina principal de la pràctica
			
			bl ord_result			@;ordena matriu de resultats
			
			bl fixar_unics			@;col·loca els resultats amb un únic valor
			
			cmp r0, #1				@;verifica si s'han efectuat canvis
			beq _start				@;en cas afirmatiu, torna a calcular
	fi_start:
			b fi_start				@;fi del programa (bucle infinit)



	@;- Funció 'fixar_unics' -> si hi ha caselles on només hi ha un possible resultat, canvia-ho al sudoku
	@;-	resultats:
	@;- R0 : =1 -> ha canviat la matriu del sudoku, =0 -> no s'ha aplicat cap canvi
	fixar_unics:
			push {lr}
			ldr r0, =sudoku_input	@;carrega adreça matriu de sudoku en R0
			ldr r4, =sudoku_output	@;carrega adreça matriu de resultats en R4
			mov r5, #0				@;R5 = índex fila resultats ordenats
			add r6, r4, r5, lsl #4	@;R6 = adreça fila resultats
			ldrb r3, [r6, #2]		@;R3 = valor actual del comptador de possibles resultats
			cmp r3, #0
			beq .Lfi_no_unics		@;si s'ha tancat el sudoku, ves al final
			cmp r3, #1
			bne .Lfi_no_unics		@;si no tenim caselles amb un sol possible resultat, ves al final
		.Lbuc_start:
			ldrb r1, [r6]			@;R1 = fila del sudoku
			ldrb r2, [r6, #1]		@;R2 = columna del sudoku
			mov r7, #3				@;R7 = índex columna resultats
		.Lno_trobat:
			ldrb r3, [r6, r7]		@;R3 = valor de possibles resultats
			add r7, #1
			cmp r3, #0				@;repeteix mentre vagi trobant zeros
			beq .Lno_trobat
			
			add r7, r2, r1, lsl #4	@;R7 = offset fila,columna sudoku
			strb r3, [r0, r7]		@;guarda el valor únic en la casella corresponent del sudoku
			
			add r5, #1
			add r6, r4, r5, lsl #4	@;R6 = adreça fila resultats
			ldrb r3, [r6, #2]		@;R3 = valor actual del comptador de possibles resultats
			cmp r3, #1
			beq .Lbuc_start			@;si queden valors únics, continua el bucle
			mov r0, #1				@;si ha acabat, recalcula els nous valors
			b .Lfi_unics
		.Lfi_no_unics:
			mov r0, #0				@;marcar que no s'ha canviat el sudoku 
		.Lfi_unics:
			pop {pc}
			



	@;- Funció 'ord_result' -> ordena les files de la matriu de resultats segons el comptador
	@;- de possibles resultats, de més petit a més gran, i afegeix una fila a '-2' per marcar
	@;- el final de la taula de resultats
	@;-	paràmetres:
	@;- R4 : adreça base de la matriu de resultats
	@;- R5 : número de files de resultats
	ord_result:
			push {r0-r3,r6,r7, lr}	@;salva a la pila els registres a modificar
			
			mov r6, #0				@;R6 = índex bucle principal
			add r3, r6, #1			@;R3 = una fila més que l'índex de fila ordenada actual
			cmp r3, r5				@;verifica si (fila_actual+1 >= num_files_resultat)
			bhs .Lfib_ord1			@;en cas afirmatiu, no entra en el bucle principal
		.Lbuc_ord1:
			mov r1, r6				@;R1 = índex fila amb valor mínim de comptador de possibles resultats
			add r0, r4, r6, lsl #4	@;R0 = adreça fila bucle primari
			ldrb r2, [r0, #2]		@;R2 = valor mínim actual del comptador
			
			mov r7, r3				@;R7 = índex bucle secundari (comença en la següent fila de l'última ordenada)
		.Lbuc_ord2:
			lsl r0, r7, #4			@;R0 = offset fila bucle secundari
			add r0, r4				@;R0 = adreça fila bucle secundari
			ldrb r3, [r0, #2]		@;R3 = valor actual del comptador de possibles resultats
			cmp r3, r2				@;compara valors de comptadors
			bhs .Lno_minim			@;si (R3 major o igual a R2), no fa intercanvi
			mov r1, r7				@;altrament, actualitza índex fila amb valor mínim
			mov r2, r3				@;i el valor mínim actual
		.Lno_minim:
			add r7, #1				@;avança índex secundari
			cmp r7, r5				@;verifica si bucle secundari arriba a l'última fila de resultats
			bne .Lbuc_ord2			@;en cas negatiu, continua el bucle secundari
			
			cmp r1, r6				@;verifica si fila amb valor mínim es diferent a fila bucle primari
			beq .Lno_swap			@;si són iguals, no cal fer l'intercanvi de files (swap)
			bl swap_files			@;altrament, fa l'intercanvi
		.Lno_swap:
			
			add r6, #1				@;avança índex primari
			add r3, r6, #1			@;R3 = una fila més que l'índex de fila ordenada actual
			cmp r3, r5				@;verifica si (fila_actual+1 == num_files_resultat)
			bne .Lbuc_ord1			@;en cas negatiu, continua el bucle principal
		.Lfib_ord1:

			mov r6, #0
			sub r6, #2				@;R6 = -2 (marca de final de llista ordenada)
			add r0, r4, r5, lsl #4	@;R0 = adreça més enllà de l'última fila de resultats
			mov r1, #0				@;R1 = índex columna
		.Lfinal_ord:
			strb r6, [r0, r1]		@;marca última posició
			add r1, #1
			cmp r1, #16				@;bucle per a totes les columnes de matriu de resultats
			bne .Lfinal_ord
			
			pop {r0-r3,r6,r7, pc}	@;restaura registres i retorna de la rutina



	@;- Funció 'swap_files' -> intercanvia el contingut (12 columnes) de dues files de la matriu de resultats
	@;- paràmetres:
	@;- R4 : adreça base de la matriu de resultats
	@;- R1 : índex d'una fila
	@;- R6 : índex de l'altra fila
	swap_files:
			push {r0-r3,r7, lr}		@;salva a la pila els registres a modificar
			
			add r2, r4, r1, lsl #4	@;R2 = adreça base d'una fila
			add r7, r4, r6, lsl #4	@;R7 = adreça base de l'altra fila
			mov r0, #0				@;R0 = índex de columna a intercanviar
		.Lbuc_swap:					@;bucle per a totes les columnes
			ldr r3, [r2, r0]		@;carrega 4 bytes d'una fila en R3
			ldr r1, [r7, r0]		@;carrega 4 bytes de l'altra fila en R1
			str r1, [r2, r0]		@;actualitza la primera fila amb el valor de la segona
			str r3, [r7, r0]		@;actualitza la segona fila amb el valor de la primera
			add r0, #4				@;avança índex en 4 columnes de cop!
			cmp r0, #12
			bne .Lbuc_swap
			
			pop {r0-r3,r7, pc}		@;restaura registres i retorna de la rutina


.end
