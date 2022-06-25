/**
* Name: TP1
* Based on the internal empty template. 
* Author: DJIMELI TIONA DARISTE
* Tags: 
*/


model TP1

/* Insert your model definition here */

global {
	int nb_tree <- 100 parameter: 'Number of tree' category: 'tree' min:20 max:200;
	int nb_pompier <- 5 parameter: 'Number of pompiers' category: 'pompier' min:1 max:50;
	int max_taille <- 5 parameter: 'Max size of tree' category: 'tree' min:1 max:10;
	int nb_fire <- 5 parameter: 'Number of fire' category: 'Fire' min:1 max:10;
	int max_range <- 60 parameter: 'neighbours distance' category: 'tree' min:10 max:100;
	int range <- 50 parameter: 'neighbours distance' category: 'tree' min:10 max:100;		
	int nb_center <- 1 parameter: 'Number of centers' category: 'pompier' min:1 max:10;	
		
	
	init {
		create tree number: nb_tree {
			size <- rnd(max_taille);
			color <- rgb([0, 100+rnd(55),0]);
		}
		
		create tree_burning number: nb_fire {			
			
		}
		
		create control_center number: nb_center {			
			
		}
		
		create pompier number: nb_pompier {
			range <- rayon_perception;
			rechargeWater <- one_of(control_center);
		}		

	}

}

species name: pompier skills: [moving] {	
	
	rgb color init: rgb('blue');
	float size init: 3.0;
	int range;
	int rayon_perception <- 10 + rnd(10);
	tree_burning but <- nil;
	int rayon_arroser <- 9;
	int rayon_recharger <- 3;	
	float vitesse <- 3.0;
	int power_augmente <- 3;
	int capacite_initial <- power_augmente + rnd(97);
	int capacite <- capacite_initial;		
	control_center rechargeWater;
	
	
	
	reflex patrolling when: (but = nil){
		do action: wander amplitude:180;
	}
	
	//detecter les buts (arbres entrain de bruler)
	reflex but_detection when: (but=nil) {
		list tmp <- list (tree_burning) where ((each distance_to self) < rayon_perception);
		
		if (length(list) > 0){
			
			but <- first(tmp sort_by (self distance_to each ));
		}
		
		//Choisir l'arbre brulé le plus proche comme but
	}
	
	//recharger le but
	reflex recharger when: (capacite <= 0){
		//s'il est loin du centre de controle, alors, aller au centre de controle
		if((self distance_to rechargeWater) > rayon_recharger) {			
			do action: goto target: rechargeWater speed: vitesse;
		}
				
		//si le but est dans le rayon_arroser, arroser le but
		if((self distance_to rechargeWater) < rayon_recharger){
			
			capacite <- capacite_initial;
		}
		
		
	}
	
	
	//arroser le but
	reflex arroser when: ((but != nil) and (capacite > 0)){
		//s'il est loin du but, alors, aller vers le but
		if((self distance_to but) > rayon_arroser) {	
					
			do action: goto target: but speed: vitesse;
		}else if(capacite > 0){
			
			capacite <- capacite - power_augmente;
			
			ask but {
				set power <- power+ myself.power_augmente;
				
			}					
			
			if(but.power >= 100){
				create tree number: 1 {
					location <- myself.but.location;
					size <- myself.but.size;
				}
				ask but {
					do die;
				}
				but <- nil;
				
			}
			
			
		}
		
		
	}
	
	
	
	aspect basic {
		draw triangle(size) color: color;
	}
}


species name: tree_burning skills: [] {
	
	int seuil <- 50;
	int duration <- 0;
	float size init: 5.0;
	int power <- 100;
	int power_diminue <- 1;
	int range <- max_range;
	
	rgb color init: rgb('red');	
	
	aspect basic {
		draw circle(size) color: color;
	}
	
	
	reflex burning {
		
		power <- power - power_diminue ;
		color <- rgb( [255,rnd(255), 0]); 
		if(power < 0){
			create tree_dead number: 1 {
				location <- myself.location;
			}
			do die;
		}
				
		//propagation des feux
		if(flip(0.01)){
			ask target:list (tree) where ((each distance_to self) < range){
				create tree_burning number: 1 {
					location <- myself.location;
					size <- myself.size;
				}
				//se tuer
				do die;
			}
		}
		
	}
	
	
}

species name:tree_dead skills:[] {
	rgb color init: rgb('black');
	float size init: 3.0;
		
	aspect basic {
		draw circle(size) color: color;
	}
	
}


species name:control_center skills:[] {
	rgb color init: rgb('yellow');
	float size init: 3.0;
	//int capacite <- rnd(100);
		
	aspect basic {
		draw square(size) color: color;
	}
	
}

species name:tree skills:[] {
	rgb color init: rgb('green');
	float size init: 5.0;
	
	aspect basic {
		draw circle(size) color: color;
	}
	
}


experiment TP type: gui {
	output {
		display Forest {
		//
			species tree aspect: basic;
			species pompier aspect: basic;
			species tree_burning aspect: basic;
			species tree_dead aspect: basic;
			species control_center aspect: basic;
		}
		
		display tree_distribution{
			chart "td_diagram" type:pie{
				data "under_4m" value:length (list (tree) where (each.size < 4) );
				data "over_7m" value:length (list (tree) where (each.size > 7) );
				data "between 4m and 7m" value:length (list (tree) where ((each.size >= 4) and (each.size <= 7)) );			
						
			}
		}

	}
	}
	
	
