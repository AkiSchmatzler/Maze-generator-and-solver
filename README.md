# Random labyrinth generator and labyrinth-solver in MIPS assembly  

### This project was part of the Computer Architecture class at the University of Strasbourg (3rd Semester)  

### Some info  
This program is written in MIPS assembly code, and uses the Mars MIPS simulator. I included the .jar file in case someone wants to execute the code.  
:warning: All the comments and function names are in french!  


### Compilation and execution  
To generate a random labyrinth, use command `java -jar Mars4_5.jar projet.s pa 1 <SIZE_LABYRINTH> <name_of_output_file>.txt`. (if the output file doesn't exist it will get created)  
To see what that labyrinth looks like, use command `print_maze.sh <name_of_output_file>.txt`   
To solve a labyrinth that is in a text file, use command `java -jar Mars4_5.jar projet.s pa 2 <name_of_labyrinth_file>.txt <name_of_output_file>.txt` (the labyrinth file must contain a valid labyrinth) 