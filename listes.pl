trader_depart(R):-marchandise(X),length(X,L), random(1,L,R).
afficher_liste([]).
afficher_liste([X]) :- write(X).
afficher_liste([X|L]) :- afficher_liste(X), nl, afficher_liste(L).

afficher_trader:- write('La position du trader est : '),nl,trader(T), print(T), write('. '),marchandise(M),pile(M,T,Res),print(Res),nl.
afficher_bourse:-write('La bourse actuelle est : '), nl, bourse(X) ,print(X),nl.

afficher_tableau([T|Q], Num):-write(Num), write('. '),write(T), nl, Num2 is Num+1,afficher_tableau(Q,Num2).
afficher_tableau([],_).

afficher_marchandise:-write('les piles de marchandises sont : '), nl, marchandise(X), afficher_tableau(X,1).

afficher_reserves:-write('les mains des joueurs sont : '),nl, reserve(R), afficher_tableau(R,1).

affiche_gagnant('Egalité'):-write('Pas de gagnant, égalité ! '),!.
affiche_gagnant(Gagnant):-write('Le gagnant est le '), write(Gagnant), write('!'),nl.

affiche_score(J1,J2):-write(J1), write(' - '), write(J2), nl.
affiche_resultat(J1,J2,Gagnant):- affiche_score(J1,J2), affiche_gagnant(Gagnant).

infos:-afficher_reserves,nl, afficher_bourse,nl, afficher_trader,nl, afficher_marchandise.

/*Retourne le Neme élément d'un tableau*/
pile([],_,[]).
pile([T|_],1,T):-!.
pile([_|Q],N,Res):- N1 is N-1,pile(Q,N1,Res).

concat([],L,L).
concat([T|L1],L2,[T|L3]):-concat(L1,L2,L3).

ajout(X,L,[X|L]).

top_pile(X,[X|_]).

/*Donne la position de l'élément X dans une liste,
  Ou retourne l'élément X de la liste à la position N)
  Renvoie faux lorsqu'impossible.
*/
element(X,[X|_],1):-!.
element(X,[_|L],N):- element(X,L,Temp),N is Temp+1,!.

/*Retourne la différence de position entre AncVal et la nouvelle position de X dans Liste
  Retourne 0 si X n'est pas dans la liste*/
diff(X,Liste,AncVal,Diff):- element(X,Liste,Position), Diff is AncVal-Position,!.
diff(_,_,_,0).

/*Lance le mode joueur contre joueur*/
jcj:- annuler, init_jcj, marchandise(M), length(M,L), boucle(1,1,L).

/*Lance le plateau de départ. (testé et fonctionnel)*/
init_jcj:- assertz(bourse([(ble,7),(riz,6),(cacao,6),(cafe,6),(sucre,6),(mais,6)])),
		   assertz(reserve([[],[]])),
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
		   assertz(trader(T)).
		   
/*Vide le plateau*/
annuler :- retractall(bourse(_)), retractall(reserve(_)), retractall(marchandise(_)), retractall(trader(_)), retractall(plateau(_)).

/*Boucle les tours de jeu jusqu'à qu'ils ne restent que 2 piles*/
boucle(J,Suiv,Num):- Num > 2, infos, coup_joueur(J), JSuivant is J+Suiv, NouvSuiv is -Suiv, marchandise(M), length(M,L), boucle(JSuivant,NouvSuiv,L),!.
boucle(_,_,_):- afficher_bourse, calcule(SommeJ1,SommeJ2,Gagnant), affiche_resultat(SommeJ1,SommeJ2,Gagnant).

/*Demande un coup valide au joueur J, puis l'execute*/
coup_joueur(J):- demander_coup(X,ResStored,NumPileWasted,NPR), jouer_coup(J,X,ResStored,NumPileWasted,NPR).

/*Demande un coup valide à l'utilisateur*/
demander_coup(X,ResStored,NumPileWasted,NPR):- mouv_trader(X), choix_ressource(X,ResStored,NumPileWasted,NPR).

/*Ajoute la piece gardée à la reserve du joueur J,
  Met à jour les piles de marchandises et la bourse pour la piece jetée,
  Met à jour le trader par rapport aux piles potentiellement supprimées,
  Puis met à jour le trader par rapport aux déplacements voulus par l'utilisateur.
  */
jouer_coup(J,X,ResStored,NumPileWasted,NPR):-reserve(R), modif_reserve(J,R,ResStored),
											 marchandise(M), nouv_pos_trader(M,X,HypPos), pile(M,HypPos,PileTrader),
											 maj_marchandisebourse(NumPileWasted,NPR),
											 modifier_trader(HypPos,PileTrader),!.
											 
jouer_coup(J,X,Reserve,March,Trader,B,Res,NumJette,NumGarde,NouvR,NouvM,NouvT,NouvB):- modif_reserve(J,Reserve,Res,NouvR),
																nouv_pos_trader(March,X,Trader,HypPos), pile(March,HypPos,PileTrader),
																maj_marchandisebourse(NumJette,NumGarde,March,NouvM,B,NouvB),
																modifier_trader(NouvM,HypPos,PileTrader,NouvT),!.

/*Demande un choix valide de déplacement du trader (fonctionnel)*/
mouv_trader(X):-nl, write('De combien voulez-vous deplacer le trader ?'),nl, write('Rep: '),
				read(X),X=<3,X>0,!.
mouv_trader(X):-write('Erreur, vous devez bouger le trader d\'entre une et trois piles, recommencez'), mouv_trader(X).

/*Demande un choix valide de ressource à garder(fonctionnel)*/
choix_ressource(X,ResStored,NPW,NPR):-  marchandise(M),length(M,Taille), trader(T), NT is T + X, abord(NT,Gauche,Droite,Taille),
									    pile(M,Gauche,PileAdj1), pile(M,Droite,PileAdj2),
									    top_pile(A,PileAdj1), top_pile(B,PileAdj2),
									    write('quelle est la ressource que vous voulez garder entre : '),
									    print(A), write(' et '), print(B), write('?'),nl,
									    read(Resp),verif_existence(Resp,A,B,Gauche,Droite,NPW,NPR), ResStored=Resp,!.
choix_ressource(X,ResStored,NPW,NPR):- write('veuillez choisir une ressource valide, recommencez'),nl, choix_ressource(X,ResStored,NPW,NPR).

/*donne les chiffres des piles à extraire selon la taille du plateau de marchandise*/
abord(Num,Taille,Droite,Taille):- Num == 1, Droite is Num+1,!.
abord(Num,Gauche,Droite,Taille):- Num+1 =< Taille,Gauche is Num-1,Droite is Num+1,!.
abord(Num,Gauche,1,Taille):- Num == Taille,Gauche is Num-1, !.
abord(Num,Taille,Droite,Taille):- Res is Num mod Taille, Res == 1, Droite is Res+1,!.
abord(Num,Gauche,Droite,Taille):- Res is Num mod Taille, Gauche is Res-1, Droite is Res+1 .

				
/* Teste si X correspond à l'un des deux autres arguments passé, et renvoie celui qui ne correspond pas.(fonctionnel)*/
verif_existence(X,X,_,NB2,NB,NB,NB2):-!.
verif_existence(X,_,X,NB,NB2,NB,NB2).

/*Ajoute NewRes dans la reserve du joueur passé en paramètre(testé et fonctionnel)*/
modif_reserve(1,[J1,J2],NewRes):- NRes = [[NewRes|J1],J2], retractall(reserve(_)),assertz(reserve(NRes)),!.
modif_reserve(2,[J1,J2],NewRes):- NRes = [J1,[NewRes|J2]], retractall(reserve(_)),assertz(reserve(NRes)),!.
modif_reserve(1,[J1,J2],NewRes,[[NewRes|J1],J2]):-!.
modif_reserve(2,[J1,J2],NewRes,[J1,[NewRes|J2]]):-!.

/*Enlève la tête des piles NumPile et NPR, met la bourse à jour en enlevant 1 à la tete de NumPile(testé et fonctionnel)*/
maj_marchandisebourse(NumPile,NPR):-marchandise(M),pile(M,NumPile,[T|Q]), modif_bourse(T),
							        remplace(Q,NumPile,M,NM), pile(NM,NPR,[_|Q2]),
									remplace(Q2,NPR,NM,NM2), retire(NM2,[],NouvM),
							        retractall(marchandise(_)),assertz(marchandise(NouvM)).
maj_marchandisebourse(NumPile,NPR,M,NouvM,B,NouvB):- pile(M,NumPile,[T|Q]), modif_bourse(T,B,NouvB),
													remplace(Q,NumPile,M,NM), pile(NM,NPR,[_|Q2]),
													remplace(Q2,NPR,NM,NM2), retire(NM2,[],NouvM).
							
/*Diminue de 1 la valeur boursière de la ressource R (testé et fonctionnel)*/							
modif_bourse(R):- bourse(Bourse), nouv_bourse(Bourse,R,NouvBourse), retractall(bourse(_)), assertz(bourse(NouvBourse)).
modif_bourse(R,B,NouvBourse):- nouv_bourse(B,R,NouvBourse).

nouv_bourse([(Res,0)|QB],Res,[(Res,0)|Suite]):- nouv_bourse(QB,Res,Suite),!.
nouv_bourse([(Res,Val)|QB],Res,[(Res,NewVal)|Suite]):- NewVal is Val-1, nouv_bourse(QB,Res,Suite),!.
nouv_bourse([TB|QB],Res,[TB|Suite]):- nouv_bourse(QB,Res,Suite),!.
nouv_bourse([],_,[]):-!.

/*Retire les N occurences de X de la liste et retourne la nouvelle liste (testé et fonctionnel)*/
retire([],_,[]):-!.
retire([T|Q],T,Res):-retire(Q,T,Res),!.
retire([T|Q],X,[T|Res]):-retire(Q,X,Res).

/*Remplace la pile Num par la pile Pile et retourne le nouveau tableau de marchandises (testé et fonctionnel)*/
remplace(AInserer,Num,Liste,Res):- remplacer(1,AInserer,Num,Liste,Res).
remplacer(Num,AInserer,Num,[_|Q],[AInserer|Suite]):-Num2 is Num+1, remplacer(Num2,AInserer,Num,Q,Suite),!.
remplacer(CurrNum,AInserer,Num,[T|Q],[T|Suite]):-Num2 is CurrNum+1, remplacer(Num2,AInserer,Num,Q,Suite),!.
remplacer(_,_,_,[],[]):-!.

/*change la position du trader (testé et fonctionnel)*/
modifier_trader(AncPosition,PileTrader):- marchandise(M), diff(PileTrader,M,AncPosition,Diff),
												NouvPosition is AncPosition - Diff,
												retractall(trader(_)),assertz(trader(NouvPosition)).
modifier_trader(M,AncPosition,PileTrader,NouvTrader):- diff(PileTrader,M,AncPosition,Diff),
													NouvTrader is AncPosition - Diff.

nouv_pos_trader(M,NB,NT):-trader(T), length(M,L), NB+T =< L, NT is NB+T,!.
nouv_pos_trader(M,NB,NT):-trader(T), length(M,L), NT is NB+T-L.
nouv_pos_trader(M,NB,T,NT):- length(M,L), NB+T =< L, NT is NB+T,!.
nouv_pos_trader(M,NB,T,NT):-length(M,L), NT is NB+T-L.

/*Calcule le resultat du joueur I (testé et fonctionnel)*/
calcule(SommeJ1,SommeJ2,Gagnant):-reserve([J1,J2]), calculer(J1,SommeJ1), calculer(J2,SommeJ2), gagnant(SommeJ1,SommeJ2,Gagnant).
calculer([T|Q],Somme):- bourse(B), recup_val(T,B,Val), calculer(Q,CurrSum), Somme is CurrSum + Val.
calculer([],0).

/*recup la valeur fonctionnel (testé fonctionnel)*/
recup_val(Marchandise,[(Marchandise,Valeur)|_],Valeur):-!.
recup_val(Marchandise,[_|Q],Valeur):-recup_val(Marchandise,Q,Valeur),!.
recup_val([],[],0).

/*Determine le gagnant (testé et fonctionnel)*/
gagnant(J1,J2,'Joueur 1'):- J1 > J2,!.
gagnant(J1,J2,'Joueur 2'):- J2 > J1,!.
gagnant(_,_,'Egalité').

/*Détermine les coups possibles à partir de la position courante du trader*/
coups_possibles(3,_,_,_,_,[]):-!.
coups_possibles(Mvt,Taille,M,T,J,[[J,NewMvt,A,D,G],[J,NewMvt,B,G,D]|Suite]):- Mvt < 3, NewMvt is Mvt+1,
								nouv_pos_trader(M,NewMvt,T,NM), abord(NM,G,D,Taille),
								pile(M,G,PG), pile(M,D,PD), top_pile(A,PG), top_pile(B,PD),
								coups_possibles(NewMvt,Taille,M,T,J,Suite).
								
/*Calcule le nombre d'occurence de X dans une liste*/					
nbOccur([],_,0):-!.
nbOccur([X|T],X,Y):- nbOccur(T,X,Z), Y is 1+Z,!.
nbOccur([_|T],X,Z):- nbOccur(T,X,Z).

/*calcule la valeur d'un coup en cherchant à obtenir la valeur la plus grande possible*/
maximise(J,Res,NumJette,M,B,R,Valeur):-recup_val(Res,B,V), val_perdue(J,M,R,NumJette,VP), Valeur is V - VP.

/*Calcule la valeur d'un coup en cherchant à obtenir la valeur la plus petite possible*/
minimise(1,M,R,NumJette,Valeur):-val_perdue(2,M,R,NumJette,VPerdue), Valeur is VPerdue.							
minimise(2,M,R,NumJette,Valeur):-val_perdue(1,M,R,NumJette,VPerdue), Valeur is VPerdue.
							
val_perdue(J,M,R,NumJette,VPerdue):- pile(R,J,ResJ), pile(M,NumJette,[T|_]),
								    nbOccur(ResJ,T,VPerdue).
									
modulo(Prof):- 0 is Prof mod 2.				
alphabeta([J,Mvt,Res,NumJette,NumGarde],Prof,Seuil,Min,Max,Reserve,March,Trader,Bourse,Valeur):-
	Prof == Seuil, modulo(Prof),!,
	maximise(J,Res,NumJette,March,Bourse,Reserve,Valeur).
	
alphabeta([J,Mvt,Res,NumJette,NumGarde],Prof,Seuil,Min,Max,Reserve,March,Trader,Bourse,Valeur):-
	Prof == Seuil,\+(modulo(Prof)),!,
	minimise(J,March,Reserve,NumJette,Valeur).
	
alphabeta([J,Mvt,Res,NumJette,NumGarde],Prof,Seuil,Min,Max,Reserve,March,Trader,Bourse,Valeur):-
	jouer_coup(J,Mvt,Reserve,March,Trader,Bourse,Res,NumJette,NumGarde,NouvR,NouvM,NouvT,NouvB),
	length(NouvM,L),
	coups_possibles(0,L,NouvM,NouvT,J,Coups),
	meilleur(Coups,Prof,Seuil,Min,Max,NouvR,NouvM,NouvT,NouvB,Valeur).

meilleur([],Prof,_,Min,_,_,_,_,_,Min):-
	modulo(Prof).

meilleur([],Prof,_,_,Max,_,_,_,_,Max):-
	\+(modulo(Prof)).

/*Coupure*/
meilleur(_,Prof,_,Min,Max,_,_,_,_,Valeur):-
	Min >= Max,!,
	meilleur([],Prof,_,Min,Max,_,_,_,_,Valeur).
meilleur(_,Prof,_,Min,Max,_,_,_,_,Valeur):-
	Max =< Min,!,
	meilleur([],Prof,_,Max,Min,_,_,_,_,Valeur).
	
meilleur([[J,Mvt,Res,NumJette,NumGarde]|Succs],Prof,Seuil,Min,Max,Reserve,March,Trader,Bourse,Valeur):-
	NouvProf is Prof+1,
	alphabeta([J,Mvt,Res,NumJette,NumGarde],NouvProf,Seuil,Min,Max,Reserve,March,Trader,Bourse,CourValeur),
	compare(Prof,CourValeur,Min,NouvMin,Max,NouvMax),
	meilleur(Succs,Prof,Seuil,NouvMin,NouvMax,Reserve,March,Trader,Bourse,Valeur),!.

compare(Prof,CourValeur,Min,CourValeur,Max,Max):-
	modulo(Prof), CourValeur > Min, !.
	
compare(Prof,CourValeur,Min,Min,Max,CourValeur):-
	\+(modulo(Prof)), CourValeur < Max, !.
	
compare(_,_,Min,Min,Max,Max).