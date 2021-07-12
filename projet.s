		#################################################################
		################### PROJET LABYRINTHE ###########################
		##################### Aki Schmatzler ############################
		############ L2S3 Informatique - Architecture ###################
		################ Université de Strasbourg #######################
		#################################################################
		


	.data
	
buffer:		.word 5
generation:	.asciiz "############# Le labyrinthe a bien été généré! :) ###############\n###   Il se trouve dans le fichier "
resolution:	.asciiz "############# Le labyrinthe a été résolu! :) ###############\n###  La résolution se trouve dans le fichier "
newLine:	.asciiz "\n"
	.text




	jal Arguments		#pour récupérer les arguments de la ligne de commande
	move $t0 $v0		#t0 --> mode
	beq $t0 1 mode1		#si le mode choisit est 1, on va au main du mode 1	
	beq $t0 2 mode2		#sinon au mode 2


################################################################################################################################
######################################                   MAIN MODE 1                  ##########################################
################################################################################################################################
mode1:		
	
	move $s1 $v1		#$s1 --> N taille du laby
	mul $s2 $s1 $s1 	#$s2 --> N²
	
	move $a0 $s2
	jal InitTab
	move $s0 $v0		#$s0 --> pointeur sur début du tableau du laby, toutes les valeurs initialisé à 15 (murs fermés)
	
	move $a1 $s0 
	move $a2 $s1
	jal EntreSortie
	move $s3 $v0		#$s3 --> case de départ
	
	move $a0 $s2
	jal CreerTableau
	move $s6 $v0 		#s6 --> pointeur sur début du tableau de cases visités
	
	li $a0 4
	jal CreerTableau
	move $s7 $v0		#$s7 --> pointeur sur tableau de 4 entiers qui sera rempli avec les voisins à chaque fois
	
	move $s4 $s3 		#$s4 --> case courante (au début c'est la case de départ)
	
	move $a0 $s6
	move $a1 $s4
	move $a2 $s1 
	jal ajtCaseVisite	#on ajoute la case de départ aux cases visités avant de commencer la boucle
	

debut:		
	bne $s4 $s3 tant_que	#tant que la case courante n'est pas la case de départ
	
	move $a0 $s3
	move $a1 $s6
	move $a2 $s1
	move $a3 $s6
	jal voisinAlea
	bne $v0 -1 tant_que 	#ou que la case de départ a des voisins non visités
	
	j finmain1
	
tant_que:
	move $a0 $s4
	move $a1 $s6
	move $a2 $s1
	move $a3 $s6
	jal voisinAlea
	beq $v0 -1 else_main	#si la case courante n'a pas de voisin valide non visités on va dans le else pour dépiler
	move $s5 $v0		#$s5 --> voisin aléatoire de la case courante
	
	move $a0 $s4
	move $a1 $s5
	move $a2 $s0
	move $a3 $s1
	jal casserMurs		#on casse le mur entre la case courante et la case choisie
	
	sub $sp $sp 4	
	sw $s4 0($sp)		#on empile la case courante
	move $s4 $s5 		#on change de case courante
	
	move $a0 $s6
	move $a1 $s5
	move $a2 $s1 
	jal ajtCaseVisite	#et on ajoute la case aléatoire choisie au cases visités
	j debut
	
	
else_main:
	lw $s4 0($sp)		
	add $sp $sp 4		#on dépile
	j debut
	
	
finmain1:   
	move $a0 $s0
	move $a1 $s1
	jal printInFile		#on met le tableau dans un fichier
	
	la $a0 generation
	li $v0 4
	syscall
	la $a0 ($t9)
	syscall
	la $a0 newLine
	syscall 
	
	li $v0 10
	syscall
	
	
	
	
################################################################################################################################
######################################                   MAIN MODE 1                  ##########################################
################################################################################################################################

mode2:
	move $s3 $v1			#sauvegarde nom du fichier résolu
	jal saveIntFromFile		#on récupére le tableau d'entiers du fichier
	move $s0 $v0			#$s0 --> pointeur sur début tableau laby
	move $s1 $v1			#$s1 --> N taille du laby 
	
	move $t9 $s3			#une fois qu'on a chargé le contenu du laby dont le nom est en $t9, on change $t9 pour que ce
					#soit le nom du deuxieme argument (aka le nom du fichier de sortie)
	
	move $a0 $s0
	move $a1 $s1
	jal FindBeginningAndEnd		#on trouve le début et la fin du labyrinthe
	move $s2 $v0			#$s2 --> indice case début
	move $s3 $v1			#$s3 --> indice case fin
	move $s6 $s2			#$s6 --> case courante (la premiere case courante est la case de départ
	
	li $a0 4
	jal CreerTableau		#on crée un tableau de 4 pour les voisins de la case courante
	move $s4 $v0			#$s4 --> pointeur sur ce tableau
	
	mul $a0 $s1 $s1
	jal CreerTableau		#et un tableau de taille N² (cases visités)
	move $s5 $v0 			#$s5 pointeur sur tableau des cases visités
	
	li $s7 1 			#compteur d'élément que l'on met dans la pile
	
	move $a0 $s5	
	move $a1 $s2
	move $a2 $s1
	jal ajtCaseVisite		#on marque la case de départ comme visités
	
tant_que_reso:	
	beq $s6 $s3 fin_tant_que_reso	#si la case courante est la case d'arrivé on a fini
	jal indice_alea			#on choisit un voisin accessibles non visité aléatoire (= -1 si pas de voisins accessibles non visités)
	move $t0 $v0
	beq $t0 -1 else_reso		#si la case n'a pas de voisin accesibles on va dans le else pour dépiler
	
	sub $sp $sp 4
	sw $s6 0($sp)			#on empile la case courante
	
	move $s6 $t0			#on change de case courante
	
	move $a0 $s5			
	move $a1 $t0
	move $a2 $s1
	jal ajtCaseVisite		#on ajoute la nouvelle case courante aux cases visités
	add $s7 $s7 1			#on incrémente le nombre de cases empilé
	j tant_que_reso
	
else_reso:
	lw $s6 0($sp)
	add $sp $sp 4			#on dépile
	sub $s7 $s7 1			#on décremente le nombre de cases empilés
	j tant_que_reso
	
fin_tant_que_reso:			#à la fin de la résolution on marque chacune des cases de la pile comme chemin solution
	beqz $s7 fin_resolution
	
	sub $s7 $s7 1			#le compteur de cases empilé va nous servir de compteur pour la boucle
	lw $t1 0($sp)			#on load le premier mot dans la pile
	add $sp $sp 4			#on dépile
	sub $t1 $t1 1
	mul $t2 $t1 4
	add $t3 $t2 $s0			#addresse du mot 
	lw $t2 0($t3)			#on store la valeur à la case donné dans $t2
	add $t2 $t2 64			#on ajoute 64 à la valeur pour marquer que c'est un chemin solution
	sw $t2 0($t3)
	b fin_tant_que_reso

	
fin_resolution:
	move $a0 $s0
	move $a1 $s1
	jal printInFile			#puis on print dans le fichier la résolution 
	j exit
	
	
indice_alea:				#pour trouver un indice aléatoire
	subu $sp $sp 4
	sw $ra 0($sp)
	
	move $a0 $s0
	move $a1 $s6
	move $a2 $s1
	move $a3 $s4
	jal voisinValideReso		#d'abord on regarde quels sont les voisins accessibles 
	move $a0 $s5
	move $a1 $s6
	jal voisinAleaReso		#puis on en choisit un non visité parmi ceux-là (renvoie -1 s'ils on tous été visités)

	lw $ra 0($sp)
	addi $sp $sp 4
	jr $ra
	
	
exit:	
	la $a0 resolution
	li $v0 4
	syscall
	la $a0 ($t9)
	syscall
	la $a0 newLine
	syscall 
	
	li $v0 10
	syscall
	



#########################################################################################################
##########################################################	Fonction Arguments
###### entrées: les arguments en ligne de commande
###	sortie: $v0 mode et $v1 soit la taille (pour le mode 1), soit le nom du deuxieme fichier (pour le mode 2)
Arguments:
	#pas de prologue
	lw $t0 0($a1)			#Met dans $t0 le 1er argument (Le mode)
	lbu $t1 ($t0)
 	sub $s0 $t1 48			#convertir ASCII en décimal
	
	beq $s0 1 main_mode1
	beq $s0 2 main_mode2

	
main_mode1:
	lw $t1 4($a1)			#Met dans $t1 le 2ème argument (la taille)
	lw $t9 8($a1)
	move $t2 $t1 			#copie de l'adresse de base du 2eme argument
longueurArg:	
	lbu $t0 ($t1)			#Met dans $s1 la valeur ASCII du 1ère byte de $t1
	blt $t0 48 finiTaille		#Test si ce n'est pas un chiffre on arrête	
	bgt $t0 57 finiTaille		
	add $t1 $t1 1 			#Pour aller au byte suivant
	j longueurArg
finiTaille:
	sub $t3 $t1 $t2 		#$t3 --> taille du second argument
	beq $t3 2 dizaineUnite
	beq $t3 1 justeUnite

dizaineUnite:
	lb $t0 0($t2)
	lb $t1 1($t2)
	sub $t0 $t0 48			#conversion en décimal
	sub $t1 $t1 48			#conversion en décimal
	mul $t0 $t0 10
	add $v1 $t0 $t1			#$v0 contient le nombre en décimal
	j finArguments
justeUnite:
	lb $t0 0($t2)
	sub $v1 $t0 48			#$v0 contient le nombre en décimal
	j finArguments
	
main_mode2:
	lw $t9 4($a1)
	lw $v1 8($a1)
	j finArguments
	
finArguments:
	move $v0 $s0
	jr $ra	
	
###########################################################################################################
################################################	Fonction InitTab
####################################### cree un tableau de taille NxN et initialise les valeurs à 15 (murs fermés)
###	entrées: $a0: taille (en nombre d'entiers) du tableau à créer
###	Pré-conditions: $a0 >0
###	Sorties: $v0: adresse (en octet) du premier entier du tableau
###		les registres temp. $si sont rétablies si utilisées
InitTab:
###	Prologue	
	subu $sp $sp 8
	sw $s0 0($sp)
	sw $ra 4($sp)
	

	move $s0 $a0
	move $a0 $s0
	jal CreerTableau
	move $t1 $v0      # Sauvegarde du pointeur du début du tableau dans $t1

	
	li $t2 0
fill:	li $t3 15	  #qui correspond a une case avec tout les murs fermés
	li $t4 0
	beq $t2 $t0 end_init	  
	mul $t4 $t2 4
	add $t4 $t4 $t1
   	sb $t3 0($t4)
   	add $t2 $t2 1
	j fill
	
	
end_init:
	lw $s0 0($sp)
	lw $ra 4($sp)
	addi $sp $sp 8
	
	#move $v0 $t1
	jr $ra
	nop
	





###########################################################################################################
#################################	Fonction voisinsValide
###entrées: $a0: taille (en nombre d'entiers) du tableau
###	    $a1: n (entré par l'utilisateur)
###	    $a2: indice de la case du tableau (i)
###	    $a3: pointeur sur la premiere case du tableau de voisins
###Pré-conditions: $a0 >0
###		   $a2 >0 et $a2 <= $a0
###Sorties: $v0: adresse (en octet) du premier entier du tableau contenant les indice des voisins (Nord Ouest Sud Est)
###		les registres temp. $si sont rétablies si utilisés

voisinsValide:
	subu $sp $sp 32
	sw $a0 0($sp)
	sw $a1 4($sp)
	sw $a2 8($sp)
	sw $a3 12($sp)
	sw $s0 16($sp)
	sw $s1 20($sp)
	sw $s2 24($sp)
	sw $ra 28($sp)


	move $s0 $a0	#$s0 --> taille du tableau ( = carré de n)
	move $s1 $a1	#$s1 -->  n, le nombre entré par l'utilisateur
	move $s2 $a2	#$s2 --> indice de la case dont on veut déterminer les voisins
	move $t0 $a3	#$t0 --> pointeur sur début du tableau de voisins
	
	
	li $a0 4	#taille max du tableau des voisins 
	jal CreerTableau
	move $t0 $v0	#$t0 --> pointeur sur premiere case tableaux des voisins
	
	subu $s2 $s2 1  #SI ON COMMENCE PAS A COMPTER LES CASES A 0
	divu $s2 $s1
	mflo $t1	#$t1 --> numéro ligne du laby (si on commence à compter à 0)(quotient)
	mfhi $t2	#$t2 --> numéro colonne du laby (si on commence à compter à 0)(reste)
	
	
			
	#si le numéro de colonne du laby est égal à 0 ou à n-1, on sait qu'il ne peut y avoir 
#que 3 voisins max. Si le numéro de ligne est égal à 0 ou n-1, on sait qu'il y a aussi un voisin de moins

	subu $t5 $s1 1		#$t5 --> n-1
	move $t6 $t0		#copie du pointeur sur premier élement du tableau 
	
	beqz $t1 voisinOuest	#si $t1 == 0 ya pas de voisin nord, on passe a celui d'après
	

	
voisinNord:
	subu $t4 $s2 $t5	
	sw $t4 0($t0)

voisinOuest:
	beqz $t2 voisinSud	#si $t2 == 0 ya pas de voisin ouest, on passe a celui d'après
	subu $t4 $s2 1		#le voisin ouest se trouve à -1 oar rapport a la case courante
	add $t4 $t4 1
	add $t6 $t0 4		#4 = taille d'un int, on passe à la prochaine case du tableau des voisins
	sw $t4 0($t6)
	

voisinSud:
	beq $t1 $t5 voisinEst	#si $t1 == n-1 il n'y a pas de voisin sud, on passe a celui d'après
	add $t4 $s2 $t5 	#le voisin sud se trouve à +n+1 par rapport à la case courante
	add $t4 $t4 2
	add $t6 $t6 4
	sw $t4 0($t6) 
	
voisinEst:
	beq $t2 $t5 end_voisins	#si $t1 == n-1 il n'y a pas de voisin sud, on passe au suivant
	add $t4 $s2 1 		#le voisin est se trouve à +1 par rapport à la case courante
	add $t4 $t4 1
	add $t6 $t6 4
	sw $t4 0($t6) 
	


end_voisins:
	lw $a0 0($sp)
	lw $a1 4($sp)
	lw $a2 8($sp)
	lw $a3 12($sp)
	lw $s0 16($sp)
	lw $s1 20($sp)
	lw $s2 24($sp)
	lw $ra 28($sp)
	addi $sp $sp 32
	
	move $v0 $t0		#on retourne le pointeur sur le premier élement du tab de voisin
	jr $ra
	
	
	
	
###########################################################################################################
#################################	Fonction ajtCaseVisite
#################################
################################# ajt une case au tableau des cases visités
###entrées: $a0: pointeur sur un tableau de taille NxN des voisins visites
###	    $a1: indice de la case visité
###	    $a2: N (taille laby)
###
###Sorties: $v0: pas de sortie (la case a été ajouté si elle n'a pas déja été visité

ajtCaseVisite:
	#prologue:
	subu $sp $sp 4
	sw $ra 0($sp)
	
	#corps de fonction
	jal checkSiVisite	#fonction qui return 0 si la case a deja été visitée
	beqz $v0 end_acv
	
	move $t0 $a0		#$t0 --> pointeur sur début de tableau de cases visités
	move $t1 $a1		#$t1 --> indice de la case visité
	move $t2 $a2		#$t2 --> N (taille laby entré par l'utilisateur
	
	mul $t2 $t2 $t2		#$t2 --> taille du tableau de cases visités

	li $t3 0	
	move $t4 $t0		#$t4 --> copie de $t0 
	
#on va voir sur quelle case du tableau de case visité on peut écrire
loop_acv:
	beq $t3 $t2 end_acv	#si tout le tableau est rempli on quitte
	lw $t5 0($t4) 
	beqz $t5 end_loop_acv	#si la case du tableau est égale à 0 on peut aller à la fin de la boucle
	addi $t3 $t3 1
	mul $t5 $t3 4
	add $t4 $t0 $t5	#$t4 prend l'adresse de la nouvelle case a check si égale a 0
	b loop_acv
	
end_loop_acv:
	sw $t1 0($t4)		#on remplit la prochaine case du tableau des voisins visités avec l'indice 
	j end_acv
	
	
end_acv:
	lw $ra 0($sp)
	addi $sp $sp 4
	jr $ra
	
###########################################################################################################
#################################	Fonction checkSiVisite
#################################
################################# vérifie si une case a été visité
###entrées: $a0: pointeur sur un tableau de taille NxN des voisins visites
###	    $a1: indice de la case 
###	    $a2: N (taille laby)
###
###Sorties: $v0: 0 si la case est visité, 1 si la case est non visité

checkSiVisite:
	#pas de prologue
	beqz $a1 csv_no		#si l'indice de la case est 0 on retourne 0
	li $t0 0		#$t0 --> compteur pour la boucle
	move $t1 $a0		#$t1 --> copie de $a0 
	mul $t2 $a2 $a2 	#$t2 --> taille du tableau de cases visités
	
#on parcourt tout le tableau pour voir si un indice correspond 
loop_csv:
	beq $t0 $t2 csv_yes	#si on a parcouru tout le tableau on va a la fin et on retourne 1
	lw $t3 0($t1)
	beq $a1 $t3 csv_no	#si on trouve une case égale on va a la fin et on retourne 0
	beq $t3 0 csv_yes	#si on a fini de parcourir les entiers non nuls du tableau on retourne 1
	addi $t0 $t0 1
	mul $t4 $t0 4
	add $t1 $a0 $t4
	b loop_csv
	
csv_yes:			#si la case n'a pas été visité on retourne 1
	li $v0 1
	j end_csv

csv_no:				#si la case n'a pas été visité on retourne 0
	li $v0 0		
	j end_csv

end_csv:
	jr $ra





###############################################################################################
#############################################################	Fonction CreerTableau
##### arguments: $a0 --> taille du tableau à créer	
##### return: $v0 pointer sur premier entier du tableau

CreerTableau:
#prologue:
	subu $sp $sp 4
	sw $ra 0($sp)
#corps de la fonction
	li $t1 0
	beq $a0 0 fin_CreerTableau
	move $t0 $a0      # Sauvegarde de la taille du tableau
	li $v0 9          # Syscall 9 -> malloc, attends le nombre d'octets dans $a0
	mul $a0 $a0 4     # Un tableau de n entiers requiers n*4 octets, 4 étant taille d'un entier ou mot
	syscall           # Need more ram
	move $t1 $v0      # Sauvegarde du pointeur du début du tableau dans $t1


#épilogue

fin_CreerTableau:
	lw $ra 0($sp)
	addi $sp $sp 4
	move $v0 $t1
	jr $ra
   	


 
	

##################################################################################################
########################################################	Fonction VoisinAléatoire
########################################### choisit un voisin valide non vide d'une case, aléatoirement
#################################### on admet que le voisin est bien un voisin valide et non visité de la case courante
### entrées:	$a0 : indice case courante
###		$a1 : pointeur début tableau de 4 entiers, qui va etre rempli avec les voisins de la case courante
###		$a2 : N choisi par l'utilisateur
###		$a3 : pointeur sur tableau des voisins visités
######
### sortie:	l'indice d'un voisin aléatoire (retourne -1 si pas de voisin non visités)
###	
### les registres temp. $si sont rétablies si utilisées
voisinAlea:
	#prologue:
	subu $sp $sp 52
	sw $a0 0($sp)
	sw $a1 4($sp)
	sw $a2 8($sp)
	sw $a3 12($sp)
	sw $s0 16($sp)
	sw $s1 20($sp)
	sw $s2 24($sp)
	sw $s3 28($sp)
	sw $s4 32($sp)
	sw $s5 36($sp)
	sw $s6 40($sp)
	sw $s7 44($sp)
	sw $ra 48($sp)
	
	#corps de fonction:
	move $s0 $a0		#$s0 --> indice case courante
	move $s1 $a1		#$s1 --> pointeur début tableau de 4 entiers, qui va etre rempli avec les voisins de la case courante
	move $s2 $a2		#$s2 --> N choisi par l'utilisateur
	move $s7 $a3		#$s7 --> pointeur sur tableau des voisins visités
	
	mul $t0 $s2 $s2		#$t0 --> carré de N
	
	move $a3 $s1		#(argument pour voisinsValides)
	move $a0 $t0		#(argument pour voisinsValides)
	move $a1 $s2		#(argument pour voisinsValides)
	move $a2 $s0		#(argument pour voisinsValides)
	jal voisinsValide	
	move $s3 $v0		#s3 --> pointeur sur tableau de voisin
	
	li $s4 0		#compteur boucle
	li $t6 0		#compteur des voisins qui se font supprimés car déjà visité ou égale à 0
	
loop_va:
	mul $s5 $s4 4
	add $s6 $s3 $s5
	add $s4 $s4 1
	lw $s5 0($s6)
	
	move $a0 $s7		#argument pour checkSiVisite (pointeur tableau des voisins visite)
	move $a1 $s5		#argument pour checkSiVisite (indice de la case)
	move $a2 $s2		#argument pour checkSiVisite (N : taille laby)
	jal checkSiVisite	#retourne 0 pour les cases visite et les cases dont l'indice est 0
	beqz $v0 del_that
	
loop_continue:	
	bne $s4 4 loop_va
	j continue_va
	
del_that:
	li $t0 0
	sw $t0 0($s6)		#si la case a deja ete visité on la remplace par 0 dans le tableau de voisins valides
	add $t6 $t6 1
	j loop_continue
	
	
#si il y a des voisins valide non visités on en génère un aléatoirement avec le syscall 42
continue_va:
	beq $t6 4 return_moins_un
	li $a1 4
	li $v0 42
	syscall			#generates random int in range [0;4[ and stores it in $a0
	mul $t1 $a0 4
	add $t2 $s3 $t1
	lw $t3 0($t2)
	add $t4 $t4 1
	beqz $t3 continue_va	#on fait une boucle jusqu'a ce que le nombre aléatoire corresponde à une case avec un entier != de 0	
	move $v0 $t3		#des qu'on a une case contenant un indice différent de 0 on retourne cet indice
	j end_va		

#si pas de voisins valide non visités on return -1
return_moins_un:
	li $v0 -1
	j end_va

#épilogue
end_va:
	lw $a0 0($sp)
	lw $a1 4($sp)
	lw $a2 8($sp)
	lw $a3 12($sp)
	lw $s0 16($sp)
	lw $s1 20($sp)
	lw $s2 24($sp)
	lw $s3 28($sp)
	lw $s4 32($sp)
	lw $s5 36($sp)
	lw $s6 40($sp)
	lw $s7 44($sp)
	lw $ra 48($sp)
	addi $sp $sp 52
	
	jr $ra
	
 


#####################################################################################
################################################	Fonction casserMurs
##################################	casse les murs entre la case courante et un de ces voisins(admis valide)
### entrées:	$a0 : indice de la case courante
### 		$a1 : indice d'une case voisine non visité de la case courante
###		$a2 : pointeur sur le tableau contenant le laby 
###		$a3 : taille N du laby 
###Pas de sortie

casserMurs:
	#pas de prologue  
	
	#corps de la fonction
	move $t0 $a0		#$t0 --> indice de la case courante
	move $t1 $a1		#$t1 --> indice de la case voisine choisie
	move $t2 $a2		#$t2 --> pointeur sur le tableau contenant le laby
	move $t3 $a3		#$t3 --> taille N du laby
	
	sub $t0 $t0 1		#pour avoir l'indice des cases dans le tableau en commençant à compter à 0 pas à 1 
	sub $t1 $t1 1		#pour avoir l'indice des cases dans le tableau en commençant à compter à 0 pas à 1 
	
	mul $t5 $t0 4
	mul $t6 $t1 4
	add $t7 $t5 $t2 	#adresse de la case courante
	add $t8 $t6 $t2 	#adresse de la case voisine
	lw $t5 0($t7)		#$t5 --> contenu à l'indice de la case courante
	lw $t6 0($t8)		#$t6 --> contenu à l'indice de la case voisine
	
#il faut savoir si la voisine est en haut, en bas, a droite ou a gauche de la case courante
	sub $t4 $t0 $t3
	beq $t4 $t1 cM_en_haut	#si case courante - N = case voisine alors la case voisine est au dessus de la case courante
	
	add $t4 $t0 $t3
	beq $t4 $t1 cM_en_bas	#si case courante + N = case voisine alors la case voisine est en dessous de la case courante
	
	sub $t4 $t0 1
	beq $t4 $t1 cM_a_gauche	#si case courante - 1 = case voisine alors la case voisine est a gauche de la case courante

	add $t4 $t0 1
	beq $t4 $t1 cM_a_droite	#si case courante + 1 = case voisine alors la case voisine est a droite de la case courante


cM_en_haut:
	sub $t5 $t5 1		#on casse le mur du haut de la case courante
	sub $t6 $t6 4		#on casse le mur du bas de la voisine du haut
	j end_cM
	
cM_en_bas:
	sub $t5 $t5 4		#on casse le mur du bas de la case courante
	sub $t6 $t6 1		#on casse le mur du haut de la voisine du bas
	j end_cM

cM_a_gauche:
	sub $t5 $t5 8 		#on casse le mur de gauche de la case courante
	sub $t6 $t6 2		#on casse le mur de droite de la voisine de gauche
	j end_cM

cM_a_droite:
	sub $t5 $t5 2		#on casse le mur de droite de la case courante
	sub $t6 $t6 8		#on casse le mur de gauche de la voisine de droite
	j end_cM


end_cM:
	sw $t5 0($t7)		#on écrit le nouveau contenu de la case courante à l'adresse, écrasant l'ancienne donnée
	sw $t6 0($t8)		#on écrit le nouveau contenu de la case voisine à l'adresse, écrasant l'ancienne donnée
	jr $ra
	

######################################################################################
#####################################################		Fonction printInFile
###################################	print le laby dans un fichier sous la bonne forme
#### entrées: $a0 --> pointeur sur tableau du laby
####	      $a1 --> taille N du laby
###	      $a2 --> mode 1 ou 2
printInFile:
#prologue:
	subu $sp $sp 36
	sw $a0 0($sp)
	sw $a1 4($sp)
	sw $s0 8($sp)
	sw $s1 12($sp)
	sw $s2 16($sp)
	sw $s3 20($sp)
	sw $s4 24($sp)
	sw $s5 28($sp)
	sw $s6 32($sp)
	
	#corps de fonction:
	move $s0 $a0		#$s0 --> pointeur sur tableau du laby
	move $s1 $a1		#$s1 --> taille N du laby 
	
	mul $s2 $s1 $s1		#$s2 --> taille du tableau (=NxN)
	
	mul $s3 $s2 3		
	add $s3 $s3 2		#$s3 correspond au nombre de caracteres que le laby fera (avec la premiere ligne indiquant la taille
	
	move $a0 $s3
	li $v0 9
	syscall 		#on alloue le nombre de charactere qu'il faut
	move $s4 $v0		#$s4 --> pointeur sur début de chaine de caractere
	
	add $s4 $s4 $s3		#maintenant on pointe vers la fin de la chaine de caracteres

	mul $s5 $s2 4	
	sub $t6 $s1 1		#$t6 --> N-1
	li $t5 0		#compteur de saut à la ligne
	li $t3 0		#compteur d'espace
loop_pif:
	sub $s5 $s5 4
	add $t4 $s0 $s5		#$t4 pointe sur le dernier entier du tableau du laby qui n'a pas encore été ajouté a la chaine de caracteres
	
	lw $t0 0($t4)
	li $t1 10
	divu $t0 $t1
	mfhi $t0		#reste de la division euclidienne (unité)
	mflo $t1		#quotient de la division euclidienne (dizaine)
	
	add $t0 $t0 48		#trouver la valeur ascii des caracteres correspondant
	add $t1 $t1 48	
	sb $t0 0($s4)		#vu qu'on va a l'envers, on met d'abord les unités
	addi $s4 $s4 -1
	sb $t1 0($s4)		#puis les dizaines
	addi $s4 $s4 -1
	
	beq $t3 $t6 new_line_pif
	
	li $t2 32		#puis un espace (32 en ascii = space)
	sb $t2 0($s4)
	addi $s4 $s4 -1		#on ajoute 1 a chaque fois pour se décaler
	
	addi $t3 $t3 1
	b loop_pif
	
new_line_pif:	
	li $t2 10		#tout les 5 mots on fait un saut à la ligne 
	sb $t2 0($s4)
	addi $s4 $s4 -1
	
	li $t3 0		#on remet le compteur d'espace à 0
	addi $t5 $t5 1
	bne $t5 $s1 loop_pif
	
	li $t1 10
	divu $s1 $t1
	mfhi $t0		#reste de la division euclidienne (unité)
	mflo $t1		#quotient de la division euclidienne (dizaine)
	
	add $t0 $t0 48		#trouver la valeur ascii des caracteres correspondant
	add $t1 $t1 48	
	sb $t0 0($s4)		#vu qu'on va a l'envers, on met d'abord les unités
	addi $s4 $s4 -1
	sb $t1 0($s4)		#puis les dizaines




# Open (for writing) a file that does not exist
	li   $v0, 13       # system call for open file	
	la   $a0, ($t9)    # output file ($t9)
	li   $a1, 1       # Open for writing (flags are 0: read, 1: write)
	li   $a2, 0        # mode is ignored
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor 

# Write to file just opened
	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	move $a1, $s4      # address of buffer from which to write
	move $a2, $s3       # hardcoded buffer length
	syscall            # write to file

# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall            # close file
	
	#épilogue
	lw $a0 0($sp)
	lw $a1 4($sp)	
	lw $s0 8($sp)
	lw $s1 12($sp)
	lw $s2 16($sp)
	lw $s3 20($sp)
	lw $s4 24($sp)
	lw $s5 28($sp)
	lw $s6 32($sp)
	addi $sp $sp 36
	jr $ra


###########################################################################################################
#################################Fonction EntreSortie
###entrées: 
###	$a1: adresse du premiere entier du tableau
###	$a2: valeur entrer par l'utilisateur (N)
###Pré-conditions: $a0 >0
###
###return : l'indice du début du tableau
EntreSortie:	
###	prolog:
	addi  $sp $sp -32
	sw $a0 0($sp)
	sw $a1 4($sp)
	sw $a2 8($sp)
	sw $s1 12($sp)
	sw $s2 16($sp)
	sw $s3 20($sp)
	sw $s4 24($sp)
	sw $ra 28($sp)
	
	move $s1, $a1 		#sauvgarde de l'adresse du premiere entier du tableau
	move $s2, $a2 		#sauvgarde de la valeur entrer par l'utilisateur

#random sauvgarder dans $a0
	li $a1 4
	li $v0 42
	syscall
	move $t0 $a0		#$t0 --> aléatoire dans range [0;3[ pour un des quatres cote
	
	li $t1 16		#le debut d'abord 
	li $t2 0		#petit compteur pour savoir quand aller à la fin
	
#si debut premiere colonne 
	beq $t0, 0, PremiereColonne
#si debut premiere ligne:
	beq $t0, 1, PremiereLigne
#si debut derniere colonne
	beq $t0, 2, DerniereColonne
#si debut dernier ligne
	beq $t0, 3, DerniereLigne

PremiereColonne:
	move $a1 $s2
	li $v0 42
	syscall
	move $t3 $a0		#$t3 --> aléatoire dans range [0;N[
	
	mul $s3 $s2 $t3		#$s3 --> indice de la case aléatoire
	
	jal ecris_adresse_laby
	
	li $t1 32
	add $t2 $t2 1		
	beq $t2 2 fin_EntreSortie	#si on a fait le debut et la fin on quitte
	jal saveDebut
	b DerniereColonne

PremiereLigne:
	move $a1 $s2
	li $v0 42
	syscall
	move $t3 $a0		#$t3 --> aléatoire dans range [0;N[
	
	move $s3 $t3		#$s3 --> indice de la case aléatoire
	
	jal ecris_adresse_laby
	
	li $t1 32
	add $t2 $t2 1		
	beq $t2 2 fin_EntreSortie	#si on a fait le debut et la fin on quitte
	jal saveDebut
	b DerniereLigne
	
DerniereColonne:
	move $a1 $s2
	li $v0 42
	syscall
	move $t3 $a0		#$t3 --> aléatoire dans range [0;N[
	
	mul $s3 $s2 $t3		#$s3 --> X*N
	add $s3 $s3 $s2		#$s3 ⁼ X*N + N
	sub $s3 $s3 1		#$s3 ⁼ X*N + N - 1
	
	jal ecris_adresse_laby
	
	li $t1 32
	add $t2 $t2 1		
	beq $t2 2 fin_EntreSortie	#si on a fait le debut et la fin on quitte
	jal saveDebut
	b PremiereColonne

DerniereLigne:
	move $a1 $s2
	li $v0 42
	syscall
	move $t3 $a0		#$t3 --> aléatoire dans range [0;N[
	
	mul $s3 $s2 $s2		#$s3 --> N²
	sub $s3 $s3 $s2		#$s3 = N² - N
	add $s3 $s3 $t3		#$s3 = N² - N + X
	
	jal ecris_adresse_laby
	
	li $t1 32
	add $t2 $t2 1		
	beq $t2 2 fin_EntreSortie	#si on a fait le debut et la fin on quitte
	jal saveDebut
	b PremiereLigne
	
saveDebut:
	add $s4 $s3 1		#car on commence à compter les cases à 1
	jr $ra

ecris_adresse_laby:
	mul $t6 $s3 4		#on multiplie l'indice par 4, taille d'un octet
	add $t5 $s1 $t6		#addresse de la case aléatoire
	lw $t6 0($t5)
	add $t6 $t6 $t1		#on ajoute soit 16 soit 32 à la case
	sw $t6 0($t5)		#on remet la valeur modifié à sa place
	
	jr $ra
	
fin_EntreSortie:
#epilogue
	move $v0 $s4 

	lw $a0 0($sp)
	lw $a1 4($sp)
	lw $a2 8($sp)
	lw $s1 12($sp)
	lw $s2 16($sp)
	lw $s3 20($sp)
	lw $s4 24($sp)
	lw $ra 28($sp)
	addi $sp $sp 32
	
	jr $ra


###########################################################################################
########################################################## fonction FindBeginningAndEnd
######################################## trouve l'indice du début du labyrinthe
####	entrées:	$a0 pointeur sur début du tableau laby
###			$a1 N
###	sorties:	$v0 indice de la case de départ
###			$v1 indice de la case de fin

FindBeginningAndEnd:
	#pas de prologue
	li $t0 0	#compteur
	move $t1 $a0
	li $t4 0
loop_fbae:		#on parcourt le tableau
	mul $t1 $t0 4
	add $t1 $a0 $t1
	lw $t2 0($t1)
	bgt $t2 16 got_one	#si une case est supérieur à 16 c'est peut-etre le début
nope:	add $t0 $t0 1
	j loop_fbae


got_one:
	bgt $t2 32 got_end	#sauf si elle est aussi supérieur à 32 (dans ce cas c'est la fin), on retourne dans la boucle
	add $t0 $t0 1
	move $v0 $t0 		#on store l'indice de début dans $v0
	add $t4 $t4 1		#on incrémente le compteur de début et de fin
	beq $t4 2 end_fbae	# si on a trouvé les 2 on fini
	b loop_fbae
	
got_end:
	add $t0 $t0 1
	move $v1 $t0		#on store l'indice de fin dans $v1
	add $t4 $t4 1		#on incrémente le compteur de début et de fin
	beq $t4 2 end_fbae	# si on a trouvé les 2 on fini
	b loop_fbae
	
end_fbae:	
	#pas d'épilogue
	jr $ra

###########################################################################################
##################################################	fonction saveIntFromFile
#####################################	lis une chaîne de caracteres d'un fichier et la stock dans un tab
###	sorties:	$v0 pointeur sur le tableau d'entiers en résultant
###			$v1 taille N du tableau
saveIntFromFile:
	#prologue
	subu $sp $sp 40
	sw $a0 0($sp)
	sw $a1 4($sp)
	sw $s0 8($sp)
	sw $s1 12($sp)
	sw $s2 16($sp)
	sw $s3 20($sp)
	sw $s4 24($sp)
	sw $s5 28($sp)
	sw $s6 32($sp)
	sw $ra 36($sp)
	
	# Open (for reading) a file
	li $v0, 13       # system call for open file
	la $a0 ($t9)     # output file ($t9)
	li $a1, 0        # flag to read
	syscall          # open a file (file descriptor returned in $v0)

	move $s6, $v0    # save file descriptor in $t0		

#tout d'abord on regarde la taille du labyrinthe pour savoir quelle taille de tableau il nous faut

	# Read to file just opened  
	li $v0, 14      # system call for read to file
	la $a1, buffer  # address of buffer to which to write
	li $a2, 2      	# hardcoded buffer length
	move $a0, $s6   # put the file descriptor in $a0		
	syscall		# write to file

	la $t1, buffer	#load the address into $t1
	lb $t2 0($t1)	#chiffre des dizaines de la taille du laby
	lb $t3 1($t1)	#chiffre des unités de la taille du laby
	
	add $t2 $t2 -48	# pour passer de la valeur ascii à la valeur décimal
	add $t3 $t3 -48
	
	mul $t2 $t2 10	#on multiplie le chiffre des dizaines par 10
	add $s1 $t3 $t2	#et on y ajoute le chiffre des unités 

#puis on crée les tableaux, un qui contiendra les caracteres et un qui contiendra les entiers après transformation 
	
	mul $s2 $s1 $s1	#N² pour la taille du tab 
	mul $s5 $s2 3	#3N², nombre de caracteres dans un fichier laby de taille N
	
	move $a0 $s5	
	jal CreerTableau
	move $s3 $v0	#pointeur sur début du tableau de characteres
	
	mul $a0 $s2 4	#on multiplie par la taille d'un entier pour le tableau  
	jal CreerTableau
	move $s4 $v0	#pointeur sur début du tableau d'entiers

#et on remplit le tableau de caracteres	

	# Read to file just opened  
	li $v0, 14      # system call for read to file
	move $a1 $s3    # address of buffer to which to write
	move $a2, $s5  	# hardcoded buffer length
	move $a0, $s6   # put the file descriptor in $a0		
	syscall		# write to file
	
	# Close the file 
	li $v0, 16       # system call for close file
	move $a0, $s6    # Restore fd
	syscall          # close file

	add $s3 $s3 1
	move $t3 $s4
	li $t4 0
	
loop:	lb $t0 0($s3)	#chiffre des dizaines
	lb $t1 1($s3)	#chiffre des unités
	
	add $t0 $t0 -48	#on passe de l'ascii au décimal
	add $t1 $t1 -48	
	
	mul $t0 $t0 10	#on multiplies le chiffre des dizaines par 10
	add $t2 $t0 $t1	#et on y ajoute le chiffre des unités
	sw $t2 0($t3)	#on ajoute ce nombre au tableau d'entiers
	
	add $t3 $t3 4	#on incrémente le pointeur sur tableau d'entiers
	add $s3 $s3 3	#on incrémente le pointeur sur tableau de char pour pointer sur le prochain début d'entier
	add $t4 $t4 1
	
	bne $t4 $s2 loop
	
	move $v0 $s4
	move $v1 $s1
	#épilogue 
	
	lw $a0 0($sp)
	lw $a1 4($sp)	
	lw $s0 8($sp)
	lw $s1 12($sp)
	lw $s2 16($sp)
	lw $s3 20($sp)
	lw $s4 24($sp)
	lw $s5 28($sp)
	lw $s6 32($sp)
	lw $ra 36($sp)
	addi $sp $sp 40
	jr $ra

	
#######################################################################################
#####################################################	Fonction voisinValideReso
############################## choisis un voisin aléatoire dans un labyrinthe
####	entrées:	$a0 pointeur sur tab du laby
####			$a1 indice de la case
###			$a2 N
###			$a3 pointeur sur tab de 4 entiers
###	sortie:		$v0 pointeur sur tab de 4 entiers

voisinValideReso:
	#prologue:
	subu $sp $sp 32
	sw $a0 0($sp)
	sw $a1 4($sp)
	sw $a2 8($sp)
	sw $a3 12($sp)
	sw $s0 16($sp)
	sw $s1 20($sp)
	sw $s2 24($sp)
	sw $s3 28($sp)
	
	move $s0 $a0	#$s0 pointeur sur tab du laby
	move $s1 $a1	#$s1 indice de la case
	move $s2 $a2	#$s2 N
	move $s3 $a3	#$s3 pointeur sur tab de 4 entiers
	
	sub $t0 $s1 1
	mul $t1 $t0 4
	add $t2 $t1 $s0
	lw $t0 0($t2)	#$t0 contenu de la case d'indice donné
	
	li $t3 0	#compteur boucle
	move $t4 $s3	#copie pointeur sur tab de 4 entiers

loop_vvr:
	li $t5 2	
	div $t0 $t5
	mflo $t0	#$t0 quotient de la division par 2
	mfhi $t2	#$t2 reste de la division par 2
	
	beqz $t2 no_wall#si $t2 est égale à 0 on ajoute un 1 au tableau
	b theres_a_wall	#sinon on ajoute un 0
back_vvr:
	add $t3 $t3 1
	mul $t1 $t3 4
	add $t4 $s3 $t1		#$t4 pointe mtn sur le prochain entier du tableau de 4 entiers
	bne $t3 4 loop_vvr
	b continue_vvr

#	le tableau d'entiers sera rempli avec des 1 ou des 0, les 1 veulent dire qu'il n'y a pas de murs, les 0 qu'il y en a
#	(pour savoir s'ils sont accessibles). Dans l'ordre, on a donc voisinHaut, voisinDroite, voisinBas, et voisinGauche.
no_wall:
	li $t5 1
	sw $t5 0($t4)
	b back_vvr
theres_a_wall:
	li $t5 0
	sw $t5 0($t4)
	b back_vvr

continue_vvr:
	lw $t1 0($s3)
	lw $t2 4($s3)
	lw $t3 8($s3)
	lw $t4 12($s3)

	beq $t1 1 Nord_vvr
cVvr1:	beq $t2 1 Est_vvr
cVvr2:	beq $t3 1 Sud_vvr
cVvr3:	beq $t4 1 Ouest_vvr
	
cVvr4:	sw $t1 0($s3)
	sw $t2 4($s3)
	sw $t3 8($s3)
	sw $t4 12($s3)
	b end_vvr
Nord_vvr:
	sub $t1 $s1 $s2
	b cVvr1
Est_vvr:
	add $t2 $s1 1
	b cVvr2
Sud_vvr:
	add $t3 $s1 $s2
	b cVvr3
Ouest_vvr:
	add $t4 $s1 -1
	b cVvr4
	
end_vvr:	
	move $v0 $s3	#on retourne un pointeur sur le tableau remplis de 0 et de 1
	#épilogue
	lw $a0 0($sp)
	lw $a1 4($sp)
	lw $a2 8($sp)
	lw $a3 12($sp)
	lw $s0 16($sp)
	lw $s1 20($sp)
	lw $s2 24($sp)
	lw $s3 28($sp)
	addi $sp $sp 32
	
	jr $ra


	
#############################################################################################
#############################################	Fonction VoisinAleaReso 
###entrées: $a0: pointeur sur un tableau de taille NxN des voisins visites
###	    $a1: indice de la case 
###	    $a2: N (taille laby)
###	    $a3: pointeur sur tableau de 4 entiers remplis des indices des voisins accessibles
###sorties: $v0: indice d'une case aléatoire 
voisinAleaReso:
	#prologue
	subu $sp $sp 48
	sw $a0 0($sp)
	sw $a1 4($sp)
	sw $a2 8($sp)
	sw $a3 12($sp)
	sw $s0 16($sp)
	sw $s1 20($sp)
	sw $s2 24($sp)
	sw $s3 28($sp)
	sw $s4 32($sp)
	sw $s5 36($sp)
	sw $s6 40($sp)
	sw $ra 44($sp)
	
	move $s0 $a0	#$s0: pointeur sur un tableau de taille NxN des voisins visites
	move $s1 $a1	#$s1: indice de la case 
	move $s2 $a2	#$s2: N (taille laby)
	move $s3 $a3	#$s3: pointeur sur tableau de 4 entiers remplis des indices des voisins accessibles
	
	li $s4 0	#compteur loop
	li $s6 0	#compteur case égale à 0
loop_var:
	mul $s5 $s4 4
	add $s5 $s5 $s3
	move $a0 $s0	#argument pour checkSiVisite (pointeur sur un tableau de taille NxN des voisins visites)
	lw $a1 0($s5)	#argument pour checkSiVisite (indice de la case)
	move $a2 $s2	#argument pour checkSiVisite (N)
	jal checkSiVisite
	move $t0 $v0
	add $s4 $s4 1	#incrémentation du compteur
	beqz $t0 del_var	#si la case à déja été visité on la remplace par 0
	bne $s4 4 loop_var
	b continue_var
	
del_var:
	li $t1 0
	sw $t1 0($s5)
	add $s6 $s6 1	#incrémentation du nombre de cases égale à 0
	bne $s4 4 loop_var
	b continue_var
	
continue_var:
	beq $s6 4 no_possibility#si toutes les cases sont égales à 0 ya pas de cases accessibles
	li $a1 4
	li $v0 42
	syscall			#generates random int in range [0;4[ and stores it in $a0
	mul $t1 $a0 4
	add $t2 $s3 $t1
	lw $t3 0($t2)
	beqz $t3 continue_var	#on fait une boucle jusqu'a ce que le nombre aléatoire corresponde à une case avec un entier != de 0	
	move $v0 $t3		#des qu'on a une case contenant un indice différent de 0 on retourne cet indice
	j end_var		
	
no_possibility:
	li $v0 -1
	j end_var
	
end_var:
	# épilogue
	lw $a0 0($sp)
	lw $a1 4($sp)
	lw $a2 8($sp)
	lw $a3 12($sp)
	lw $s0 16($sp)
	lw $s1 20($sp)
	lw $s2 24($sp)
	lw $s3 28($sp)
	lw $s4 32($sp)
	lw $s5 36($sp)
	lw $s6 40($sp)
	lw $ra 44($sp)
	addi $sp $sp 48
	
	jr $ra	   
	
