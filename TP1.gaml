/**
* Name: TP1
* Based on the internal empty template. 
* Author: DJIMELI TIONA DARISTE
* Tags: 
*/


model TP1

/* Insert your model definition here */
global {
	 int nb_tree <- 100;
	 int Nb_pompiers <- 10;
	 float vitesse <- 0.1 parameter: "vitesse" category:'Pompier' ;
	init {
		create tree number:nb_tree{}
		create pompier number:Nb_pompiers{
			speed <- vitesse;
		}
	}
}


// species TREE 
species name:tree skills:[]{
	
	rgb colore;
	float size;
	init{
		colore <- rgb('green');
		size <- 5.0;
		
	}
	aspect treeAspect{
		draw circle(size) color:colore;
	}	
}

// species POMPIER
species pompier skills:[moving] {
	rgb colore;
	float size;
	
	init{
		color <- rgb('red');
		size <- 4.0;
	}
	aspect pompierAspect{
		draw triangle(size) color:colore;
	}	
	reflex patrolling{
    do action: wander amplitude:180;
}
} 

experiment tp1 type: gui{
	parameter "Number of tree" var:nb_tree category:'Tree' min:20 max:200;
	parameter "Number of pompiers" var:Nb_pompiers category:'Pompier' min:10 max:20;

	output{
		display Forest{	
			species tree aspect:treeAspect;
			species pompier aspect:pompierAspect;
		}
	}
}

