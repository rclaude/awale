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
tour(Joueur1,Joueur2,CasePriseGraines,GrainesRamassees) :- jeu(Joueur1,Plateau),
                                                        case(CasePriseGraines,Plateau,NbGrDistrib),
                                                        NbGrDistrib\==0,
                                                        distribPlateau(0,CasePriseGraines,NbGrDistrib,Plateau,NewPlateau,CaseArrivee,NbGrainesResttes),
                                                        miseAjour(Joueur1,NewPlateau),
                                                        NbGrainesResttes\==0,
                                                        distribPlateauJ2(Joueur2,Joueur1,NbGrainesResttes,CaseA,Plat2,Ja),
                                                        CasePr is 1-CaseA,
                                                        write(CasePr),
                                                        ramasserGraines(Joueur1,Ja,CasePr,GrainesRamassees).

% distribution des graines restantes après le premier passage de "prise"
distribPlateauJ2(Joueur2,Joueur1,NbGraines,CaseArrivee,NewPlateau2,JoueurArr) :- 
											jeu(Joueur2,Plateau2),
											distribPlateau(1,1,NbGraines,Plateau2,NewPlateau2,CaseArr,NbGrainesReste),
											miseAjour(Joueur2,NewPlateau2),
											ifThenContinueDistribPlat2(Joueur1,Joueur2,NbGrainesReste,CaseArr1,Plat,JoueurArr),
											ifThenCaseArrivee(CaseArr,CaseArr1,CaseArrivee).
                                            
% outils conditionnels
ifThenContinueDistribPlat2(J1,J2,0,Case,_,J2):- !.
ifThenContinueDistribPlat2(Joueur1,Joueur2,NbGrainesReste,CaseArr,Plat,Ja):- NbGrainesReste\==0,
																			distribPlateauJ2(Joueur1,Joueur2,NbGrainesReste,CaseArr,Plat,Ja).

ifThenCaseArrivee(Case1,Case2,CaseFin):- nonvar(Case2),!,CaseFin is Case2.
ifThenCaseArrivee(Case1,Case2,CaseFin):- CaseFin is Case1,!.

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
                                                               permut(Plateau,PlateauInverse),
                                                               CaseDep is 7-CaseDepart, 
                                                               nl,write(CaseDep),nl,
                                                               recuperationGraines(PlateauInverse, CaseDep, NewPlateauInvers, GrainesRamassees),
                                                               permut(NewPlateauInvers,NewPlateau),
                                                               miseAjour(Joueur2,NewPlateau).

                                                               
recuperationGraines([], CaseCourante, [], 0):- !.
														   
% dépile sans prise
recuperationGraines([T|Q], CaseCourante, [T|N], GrainesRamassees):- CaseCourante > 1,
																	!,
                                                                    NewCase is CaseCourante-1,
																	recuperationGraines(Q, NewCase, N, GrainesRamassees).

% le cas où rien n'est ramassé
recuperationGraines([T|Q], 1, [T|Q], 0):- T > 3 ; T < 2 .	

% le cas où le joueur gagne des graines
recuperationGraines([T|Q], 1, [0|V], GrainesRamassees):- recuperationGraines(Q, 0, V, AncienNbGraine),
                                                         !,
                                                         GrainesRamassees is AncienNbGraine + T.	    
													                                                    
recuperationGraines([T|Q], CaseCourante, [0|V], GrainesRamassees):- CaseCourante < 1,
                                                                    T > 1,
                                                                    T < 4,
                                                                    !,
                                                                    NewCase is CaseCourante-1,
                                                                    recuperationGraines(Q, NewCase, V, AncienNbGraine),
                                                                    !,
                                                                    GrainesRamassees is AncienNbGraine + T.	
                                                                    
recuperationGraines([T|Q], CaseCourante, [T|Q], 0):- CaseCourante < 1,
                                                    T < 2 ; T > 3 .

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

/* ----------------------------------------------------------------------------------------------------- tests  */

% TESTS

% test distribution des graines avec la prise
testDistribPlateau(Plateau,NewPlateau,CA,NBR):- distribPlateau(1,1,15,Plateau,NewPlateau,CA,NBR).

% test distribution des graines après le passage de "prise"
testDistPlat2(CaseArr,PlateauJ2) :- distribPlateauJ2('ordi','humain',11,CaseArr,PlateauJ2,J).

% test ramasseesGraines 
testRamasse(NbG,J):- miseAjour('ordi',[6,1,3,3,2,8]), ramasserGraines('humain','ordi',4,NbG),jeu('ordi',J). 
testRamasse2(NbG,J):- miseAjour('ordi',[2,1,3,3,2,8]), ramasserGraines('humain','ordi',1,NbG),jeu('ordi',J).

% test d'un tour de jeu : prise et distribution de graines.
testTour(A,B) :- miseAjour('ordi',[1,4,2,1,4,4]),
                 miseAjour('humain',[4,4,4,4,4,4]),
                 tour('humain','ordi',6,Nbr),
                 jeu('humain',A),
                 jeu('ordi',B).

% test d'un enchainement de 2 tours de jeu
test2Tour(A,B) :-miseAjour('ordi',[1,4,2,1,6,4]),
                     miseAjour('humain',[4,2,1,0,2,4]),
                     tour('humain','ordi',6,NbrH),
                     tour('ordi','humain',5,NbrO),
                     jeu('humain',A),
                     jeu('ordi',B).	

% test de validation du jeu

testValidation():- testDistribPlateau([4,4,4,4,4,4],NewPlateau,CA,NBR),
                  !.
                   
