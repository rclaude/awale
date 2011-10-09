% conditions initiales


:- dynamic(jeu/2).
:- dynamic(score/2).
:- assert(jeu(humain,[4,4,4,4,4,4])).
:- assert(jeu(ordi,[4,4,4,4,4,4])).
:- assert(score(ordi,0)).
:- assert(score(humain,0)).



tour(humain).


% OUTILS

miseAjour(Joueur,Plateau):- retract(jeu(Joueur,_)),assert(jeu(Joueur,Plateau)).

													



/* -------------------------------------------------------------------------------------------------- traitement d'un coup */

% tour de jeu : prise et distribution des graines 
tour(Joueur1,Joueur2,CasePriseGraines,CaseA,Plat2,Ja) :- jeu(Joueur1,Plateau),
								case(CasePriseGraines,Plateau,NbGrDistrib),
								NbGrDistrib\==0,
								distribPlateau(0,CasePriseGraines,NbGrDistrib,Plateau,NewPlateau,CaseArrivee,NbGrainesResttes),
								miseAjour(Joueur1,NewPlateau),
								NbGrainesResttes\==0,
								distribPlateauJ2(Joueur2,Joueur1,NbGrainesResttes,CaseA,Plat2,Ja).

% Nombre de graines dans la case choisie
case(Case,Joueur,[T|Q],NbGraines):- jeu(Joueur,[T|Q]),case(Case,[T|Q],NbGraines).
case(Case, [T|Q], NbGraines) :- Case\==1,!,NouvCase is Case-1, case(NouvCase,Q, NbGraines).
case(1,[NbGraines|Q], NbGraines):- !.

								
/* ----------------------------------------------------------------------------- recuperer les graines gagnées */

% inversion de liste
permut([],[]):- !.
permut([T|Q],NouvListe) :- permut(Q,R), append(R,[T],NouvListe).

ramasserGraines(Joueur1,Joueur1,CaseDepart,_):- !.
ramasserGraines(Joueur1,Joueur2,CaseDepart,GrainesRamassees):- jeu(Joueur2,Plateau),
                                                               permut(Plateau,PlateauInv),
                                                               CaseDep is 7-CaseDepart, % (6-CaseDep + 1 vu que nos indices commencent à 1)
                                                               recuperationGraines(PlateauInverse, CaseDep, NewPlateauInvers, GrainesRamassees),
                                                               permut(NewPlateauInvers,NewPlat),
                                                               miseAjour(Joueur2,NewPlateau).

%recuperationGraines([], CaseCourante, [], 0):- !.																				  
																				  
														   
recuperationGraines([T|Q], CaseCourante, [T|N], GrainesRamassees):- CaseCourante > 1,
																	NewCase is CaseCourante-1,
																	recuperationGraines(Q, NewCase, N, GrainesRamassees),
																	!.

% des qu on a passé la case max où on peut ramasser, on renvoie le reste tel quel
recuperationGraines([T|Q], CaseCourante, [T|Q], 0):- CaseCourante <1;CaseCourante ==1,
													 T > 3 ; T < 2,
													!.					
																  
recuperationGraines([T|Q], CaseCourante, [0|V], GrainesRamassees):-  NewCase is CaseCourante-1,
																				   recuperationGraines(Q, NewCase, V, AncienNbGraine),
																				   !,
																				   GrainesRamassees is AncienNbGraine + T.
																					



											

/* --------------------------------------------------------------------------- Distribution sur un plateau */

/*
Conditions d'arret:
-- toutes les graines ont été distribuées
-- la fin d'un plateau est atteinte
*/

% CONDITIONS ARRET

% Toutes les graines ont été distribuées
distribPlateau(Prise,CaseCrte,NbGrDistrib,Plateau,Plateau,CaseA,NbGrR):-NbGrDistrib==0,!,CaseA is CaseCrte,NbGrR is NbGrDistrib.

% Fin du plateau atteinte
distribPlateau(Prise,CaseCrte,NbGrDistrib,[],[],CaseA,NbGrR):-CaseA is -99,NbGrR is NbGrDistrib,!.


% Outils conditionnels 

ifThenListe(Prise,Compte,T):- Prise==0,!,Compte is 0.
ifThenListe(Prise,Compte,T):- Compte is T+1.

ifThenGraines(Prise,NbGr,NbGrD):- Prise==0,!,NbGr is NbGrD.
ifThenGraines(Prise,NbGr,NbGrD):- NbGr is NbGrD-1.

ifThenContinueDistribPlat2(J1,J2,0,Case,_,J2):- !.
ifThenContinueDistribPlat2(Joueur1,Joueur2,NbGrainesReste,CaseArr,Plat,Ja):- NbGrainesReste\==0,
																			distribPlateauJ2(Joueur1,Joueur2,NbGrainesReste,CaseArr,Plat,Ja).

ifThenCaseArrivee(Case1,Case2,CaseFin):- nonvar(Case2),!,CaseFin is Case2.
ifThenCaseArrivee(Case1,Case2,CaseFin):- CaseFin is Case1,!.

% DISTRIBUTION DES GRAINES

% Copie des cases du plateau courant non affectées par la distribution dans le nouveau plateau
distribPlateau(Prise,CaseCrte,NbGrDistrib,[T|Q],[T|M],CaseArr,NbGrRestantes):- CaseCrte>1,
												 !,
												 NewCase is CaseCrte-1,
												 distribPlateau(Prise,NewCase,NbGrDistrib,Q,M,CaseArr,NbGrRestantes).
												 
% Prise des graines dans la case demandée (elle ne contiendra plus rien dans le nouveau plateau)											 
distribPlateau(Prise,CaseCrte,NbGrDistrib,[T|Q],[N|M],CaseArr,NbGrRestantes):- CaseCrte==1,
												 !,
												 ifThenListe(Prise,N,T),
												 ifThenGraines(Prise,NbGr,NbGrDistrib),
												 NewCase is CaseCrte-1,												
												 distribPlateau(Prise,NewCase,NbGr,Q,M,CaseArr,NbGrRestantes).	
											
% Ajout d'une graine par case pour les cases qui suivent celle d'où les graines ont été prises (sens anti-horaire)												 
distribPlateau(Prise,CaseCrte,NbGrDistrib,[T|Q],[P|M],CaseArr,NbGrRestantes):- CaseCrte<1,
												!,
												P is T+1,
												NewCase is CaseCrte-1,
												NewNbGraine is NbGrDistrib-1,
												distribPlateau(Prise,NewCase,NewNbGraine,Q,M,CaseArr,NbGrRestantes).

% distribution des graines restantes après le premier passage de "prise"
distribPlateauJ2(Joueur2,Joueur1,NbGraines,CaseArrivee,NewPlateau2,JoueurArr) :- 
											jeu(Joueur2,Plateau2),
											distribPlateau(1,1,NbGraines,Plateau2,NewPlateau2,CaseArr,NbGrainesReste),
											miseAjour(Joueur2,NewPlateau2),
											ifThenContinueDistribPlat2(Joueur1,Joueur2,NbGrainesReste,CaseArr1,Plat,JoueurArr),
											ifThenCaseArrivee(CaseArr,CaseArr1,CaseArrivee).
                                                
/* ----------------------------------------------------------------------------------------------------- tests  */

% TESTS

% test distribution des graines avec la prise
testDistribPlateau(Plateau,NewPlateau,CA,NBR):- jeu(humain,Plateau),distribPlateau(1,1,15,Plateau,NewPlateau,CA,NBR).

% test distribution des graines après le passage de "prise"
testDistPlat2(CaseArr,PlateauJ2) :- distribPlateauJ2('ordi','humain',11,CaseArr,PlateauJ2,J).

% test ramasseesGraines 
testRamasse(NbG,J):- miseAjour('ordi',[6,1,3,3,2,8]), ramasserGraines('humain','ordi',4,NbG),jeu('ordi',J).

% test d'un tour de jeu : prise et distribution de graines.
testTour(C,P,K) :- miseAjour('ordi',[4,4,4,4,4,4]),miseAjour('humain',[4,4,4,4,20,4]),tour('humain','ordi',5,C,P,K).

% test d'un enchainement de 2 tours de jeu
testJeu1Tour(NbG,JH,JO) :- miseAjour('humain',[4,4,4,4,4,4]),miseAjour('ordi',[4,4,4,4,4,4]),tour('humain','ordi',4,C,P2,Ja),
							%ifThenJoueur(J1,Ja,CaseArr,Case),
							Case2 is 1-C, ramasserGraines('humain','ordi',Case2,NbG),jeu('humain',JH),jeu('ordi',JO).
testJeu2Tour(NbG1,JH1,JO1) :-tour('ordi','humain',6,C1,Pl2,Ja1),
							Case3 is 1-C1, ramasserGraines('ordi','humain',Case3,NbG1),jeu('humain',JH1),jeu('ordi',JO1).		
