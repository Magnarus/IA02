trader_depart(R):-marchandise(X),length(X,L), random(1,L,R).
afficher_liste([]).
afficher_liste([X]) :- write(X).
afficher_liste([X|L]) :- afficher_liste(X), nl, afficher_liste(L).

afficher_trader:-trader(T), print(T),marchandise(M),pile(M,T,Res),print(Res).
afficher_bourse:-bourse(X) ,print(X).
afficher_marchandises:-marchandise(X), print(X).
afficher_reserves(X):-reserve(Y), nth0(X,Y,R), print(R).
afficher_plateau:-plateau(R),print(R).

pile([],_,[]).
pile([T|_],1,T):-!.
pile([_|Q],N,Res):- N1 is N-1,pile(Q,N1,Res).

concat([],L,L).
concat([T|L1],L2,[T|L3]):-concat(L1,L2,L3).

ajout(X,L,[X|L]).

init_jcj:- assertz(bourse([[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]])),
		   assertz(reserve([j1,[]],[j2,[]])),
           assertz(marchandise([[mais,riz,ble,ble],
						   [ble,mais,sucre,riz],
						   [cafe,sucre,cacao,riz],
						   [cafe,mais,sucre,mais],
						   [cacao,mais,ble,sucre],
						   [riz,cafe,sucre,ble],
						   [cafe,ble,sucre,cacao],
						   [mais,cacao,cacao,ble],
						   [riz,riz,cafe,cacao]])),
		   trader_depart(T),
		   assertz(trader(T)),
		   assertz((plateau(R) :- bourse(X),marchandise(Y),trader(Z),reserve(U),concat(X,Y,V),ajout(Z,V,W), concat(W,U,R))).

coup_joueur(J):- demander_coup(X,ResStored,ResWasted), jouer_coup(J,X,ResStored,ResWasted).

demander_coup(X,ResStored,NumPileWasted):-  write('La position du trader est : '),nl,
										afficher_trader, nl,
										write('De combien voulez-vous déplacer le trader'),nl,
										read(X),X=<3,X>0,
										marchandise(M), trader(T), NT is T+X,
										pile(M,NT,Pile),pile(M,NT-1,PileAdj1), pile(M,NT+1,PileAdj2),
										top_pile(A,PileAdj1), top_pile(B,PileAdj2),
										write('quelle est la ressource que vous voulez garder entre : '),
										print(A), write(' et '), print(B), write('?'),nl,
										read(Resp),verif_existence(Resp,A,B,NT-1,NT+1,NumPileWasted), ResStored=Resp.

jouer_coup(J,X,ResStored,NumPileWasted):- reserve(R),pile(R,J,ResJoueur). /*TODO : ajout, remette reserve, supprimé jeton pile NumPileWasted*/
jcj:- init_jcj.

top_pile(X,[X|Q]).

verif_dessus(_,[]):-fail.
verif_dessus(X,Adj):- top_pile(X,Adj),!.

/*Teste si X correspond à l'un des deux autres arguments passé, et renvoie celui qui ne correspond pas.*/
verif_existence(X,X,_,_,NB,NB):-!.
verif_existence(X,_,X,NB,_,NB).

	  