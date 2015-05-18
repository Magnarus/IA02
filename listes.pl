bourse([[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]]).
marchandise([[mais,riz,ble,ble],
			[ble,mais,sucre,riz],
			[cafe,sucre,cacao,riz],
			[cafe,mais,sucre,mais],
			[cacao,mais,ble,sucre],
			[riz,cafe,sucre,ble],
			[cafe,ble,sucre,cacao],
			[mais,cacao,cacao,ble],
			[riz,riz,cafe,cacao]]).
			
trader(R):-marchandise(X),length(X,L), random(1,L,R).

reserves(
[
	[j1,[]],
	[j2,[]]
]).


plateau(R):-bourse(X),marchandise(Y),trader(Z),reserves(U),
			concat(X,Y,V),ajout(Z,V,W),concat(W,U,R).

afficher_liste([]).
afficher_liste([X]) :- write(X).
afficher_liste([X|L]) :- afficher_liste(X), nl, afficher_liste(L).

afficher_bourse:-bourse(X) ,print(X).
afficher_marchandises:-marchandise(X), print(X).
afficher_reserves(X):-reserves(Y), nth0(X,Y,R), print(R).
afficher_plateau:-plateau(R),print(R).

concat([],L,L).
concat([T|L1],L2,[T|L3]):-concat(L1,L2,L3).

ajout(X,L,[X|L]).