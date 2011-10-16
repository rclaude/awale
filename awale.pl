% conditions initiales


:- dynamic(jeu/2).
:- dynamic(score/2).
:- assert(jeu(humain,[4,4,4,4,4,4])).
:- assert(jeu(ordi,[4,4,4,4,4,4])).
:- assert(score(ordi,0)).
:- assert(score(humain,0)).



tour(humain).


% OUTILS

miseAjourPlateau(Joueur,Plateau):- retract(jeu(Joueur,_)),assert(jeu(Joueur,Plateau)).
miseAjourScore(Joueur,Score):- retract(score(Joueur,_)),assert(score(Joueur,Score)).


/**************************************************************************************************************************
**************************************************** Mecanique du jeu ***************************************************
**************************************************************************************************************************/


/* -------------------------------------------------------------------------------------------------- traitement d'un coup */

% tour de jeu : prise et distribution des graines. Fail si il n'y a pas de graines à distribuer
tourPlat(J1,J2,P1,P2,P1Fin,P2Fin,CasePriseGraines,GrainesRamassees) :- case(CasePriseGraines,P1,NbGrDistrib),
														ifThenDistrib1(J1,J2,P1,P2,P1Fin,P2Fin,CasePriseGraines,NbGrDistrib,GrainesRamassees).

                                                       % NbGrDistrib\==0,!,
                                                       % distribPlateau(0,CasePriseGraines,NbGrDistrib,P1,NewP1,CaseArrivee,NbGrainesResttes),
                                                       % NbGrainesResttes\==0,!,
                                                       % distribPlateauJ2Plat(J2,J1,P2,NewP1,NbGrainesResttes,CaseA,P2AvtRamasse,P1Fin,Ja),
                                                       % ramasserGrainesPlat(J1,Ja,P2AvtRamasse,P2Fin,CaseA,GrainesRamassees).


ifThenDistrib1(J1,J2,P1,P2,P1,P2,CasePriseGraines,0,0):- !.
ifThenDistrib1(J1,J2,P1,P2,P1Fin,P2Fin,CasePriseGraines,NbGrDistrib,GrainesRamassees):- NbGrDistrib\==0,!,
																						 distribPlateau(0,CasePriseGraines,NbGrDistrib,P1,NewP1,CaseArrivee,NbGrainesResttes),
																						 ifThenDistrib2(J2,J1,P2,NewP1,P2Fin,P1Fin,NbGrainesResttes,GrainesRamassees).
																						 
ifThenDistrib2(J2,J1,P2,NewP1,P2,NewP1,0,0):- !.
ifThenDistrib2(J2,J1,P2,NewP1,P2Fin,P1Fin,NbGrainesResttes,GrainesRamassees):-  NbGrainesResttes\==0,!,
                                                        distribPlateauJ2Plat(J2,J1,P2,NewP1,NbGrainesResttes,CaseA,P2AvtRamasse,P1Fin,Ja),
                                                        ramasserGrainesPlat(J1,Ja,P2AvtRamasse,P2Fin,CaseA,GrainesRamassees).										 
																	
														
% distribution des graines restantes après le premier passage de "prise"
distribPlateauJ2Plat(J2,J1,P2,P1,NbGraines,CaseArrivee,NvP2,NvP1,JoueurArr) :-	distribPlateau(1,1,NbGraines,P2,NewP2,CaseArr,NbGrainesReste),
															ifThenContinueDistribPlat2Plat(J1,J2,P1,NewP2,NbGrainesReste,CaseArr1,NvP1,NvP2,JoueurArr),
															ifThenCaseArriveePlat(CaseArr,CaseArr1,CaseArrivee).	



% outils conditionnels
ifThenContinueDistribPlat2Plat(J1,J2,P1,P2,0,Case,P1,P2,J2):- !.
ifThenContinueDistribPlat2Plat(J1,J2,P1,P2,NbGrainesReste,CaseArr,Plat1,Plat2,Ja):- NbGrainesReste\==0,
														distribPlateauJ2Plat(J1,J2,P1,P2,NbGrainesReste,CaseArr,Plat1,Plat2,Ja).

ifThenCaseArriveePlat(Case1,Case2,CaseFin):- nonvar(Case2),!,CaseFin is Case2.
ifThenCaseArriveePlat(Case1,Case2,CaseFin):- CaseFin is 1-Case1,!.

                                            
% Nombre de graines dans la case choisie
case(Case,Joueur,[T|Q],NbGraines):- jeu(Joueur,[T|Q]),case(Case,[T|Q],NbGraines).
case(Case, [T|Q], NbGraines) :- Case\==1,!,NouvCase is Case-1, case(NouvCase,Q, NbGraines).
case(1,[NbGraines|Q], NbGraines):- !.


/* ------------------------------------------------------------------------------------- recuperer les graines gagnées */

ramasserGrainesPlat(J1,J1,P2,P2,CaseDepart,0):- !.
ramasserGrainesPlat(J1,J2,P2,NewP2,CaseDepart,GrainesRamassees):-  permut(P2,P2Inverse),
																   CaseDep is 7-CaseDepart,
																   recuperationGraines(P2Inverse, CaseDep, NewP2Invers, GrainesRamassees),
																   permut(NewP2Invers,NewP2).

% inversion de liste
permut([],[]):- !.
permut([T|Q],NouvListe) :- permut(Q,R), append(R,[T],NouvListe).

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


													
%tests
testDistPlat2Nouveau(CaseArr,PlatJ2,PlatJ1,J) :- distribPlateauJ2Plat('ordi','humain',[0,1,5,2,0,5],[4,1,9,5,2,0],14,CaseArr,PlatJ2,PlatJ1,J).

testRamassePlat(Ja,PlatJ2,P2Fin,PlatJ1,CaseArr,GrainesRamassees) :- distribPlateauJ2Plat('ordi','humain',[0,1,1,2,1,2],[4,1,9,5,2,0],0,CaseArr,PlatJ2,PlatJ1,J),
																	ramasserGrainesPlat('humain','ordi',PlatJ2,P2Fin,CaseArr,GrainesRamassees).
																	
testTourPlat(P1Fin,P2Fin,GrainesRamassees):- 
										tourPlat('ordi','humain',[0,1,1,2,1,2],[4,1,9,5,2,0],P1Fin,P2Fin,6,GrainesRamassees).
/* ------------------------------------------------------------------------------- Distribution sur un plateau */

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

/* ----------------------------------------------------------------------------------------------------- tests */

% TESTS

% test distribution des graines avec la prise
testDistribPlateau(Plateau,NewPlateau,CA,NBR):- distribPlateau(1,1,15,Plateau,NewPlateau,CA,NBR).

% test distribution des graines après le passage de "prise"
testDistPlat2(CaseArr,PlateauJ2) :- distribPlateauJ2('ordi','humain',11,CaseArr,PlateauJ2,J).

% test ramasseesGraines
testRamasse(NbG,J):- miseAjourPlateau('ordi',[6,1,3,3,2,8]), ramasserGraines('humain','ordi',4,NbG),jeu('ordi',J).
testRamasse2(NbG,J):- miseAjourPlateau('ordi',[2,1,3,3,2,8]), ramasserGraines('humain','ordi',1,NbG),jeu('ordi',J).

% test d'un tour de jeu : prise et distribution de graines.
testTour(A,B) :- miseAjourPlateau('ordi',[1,4,2,1,4,4]),
                 miseAjourPlateau('humain',[4,4,4,4,4,4]),
                 tour('humain','ordi',6,Nbr),
                 jeu('humain',A),
                 jeu('ordi',B).

% test d'un enchainement de 2 tours de jeu
test2Tour(A,B,C,D) :-miseAjourPlateau('humain',[4,2,1,0,2,4]),
                     miseAjourPlateau('ordi',[1,4,2,1,6,4]),
                     miseAjourScore('humain',0),
                     miseAjourScore('ordi',0),
                     tour('humain','ordi',4,NbrH),
                     tour('ordi','humain',5,NbrO),
                     jeu('humain',A),
                     jeu('ordi',B),
                     score('humain',C),
                     score('ordi',D).

% test de validation du jeu
testValidation:- miseAjourPlateau('humain',[4,2,1,0,2,4]),
                 miseAjourPlateau('ordi',[1,4,2,1,6,4]),
                 miseAjourScore('humain',0),
                 miseAjourScore('ordi',0),
                 tour('humain','ordi',6,NbrH),
                 tour('ordi','humain',5,NbrO),
                 jeu('humain',A),
                 jeu('ordi',B),
                 score('humain',C),
                 score('ordi',D),
                 A == [5,3,2,1,0,0],
                 B == [2,5,0,0,0,5],
                 C == 5,
                 D == 3 .
                 
                   
/**************************************************************************************************************************
******************************************** IA (algo => alpha beta negamax) ********************************************
**************************************************************************************************************************/

/* ----------------------------------------------------------------------------------------------- min max notre arbre spécifique */

% outils pour MinMax

% itThenIndiceCase(Tete, ValMax, CaseMax, CaseCourante, NouvValMax, NouvCaseMax)
itThenIndiceCase(Tete, ValMax, CaseMax, CaseCourante, Tete, CaseCourante):- Tete > ValMax.
itThenIndiceCase(Tete, ValMax, CaseMax, CaseCourante, ValMax, CaseMax):- !.

trouverCaseMax6SuivantListe(1,[T|Q],6,T):-!.
trouverCaseMax6SuivantListe(NbCase,[T|Q],IndiceCase, Valeur):- NouvNbCase is NbCase - 1,
																 trouverCaseMax6SuivantListe(NouvNbCase,Q,AncienIndiceCase,AncienMax),
																 CaseCourante is 7 - NbCase,
																 itThenIndiceCase(T, AncienMax, AncienIndiceCase, CaseCourante, Valeur, IndiceCase).							 

trouverMin6SuivantListe(0,L,L,99):-!.
trouverMin6SuivantListe(NbCase,[T|Q],L, Valeur):- NouvNbCase is NbCase - 1,
							                      trouverMin6SuivantListe(NouvNbCase,Q,L,AncienMin),
												  Valeur is min(T,AncienMin).
												  
trouverMax6SuivantListe(0,L,L,-99):-!.
trouverMax6SuivantListe(NbCase,[T|Q],L, Valeur):- NouvNbCase is NbCase - 1,
							                      trouverMax6SuivantListe(NouvNbCase,Q,L,AncienMax),
												  Valeur is max(T,AncienMax).		

ifThenChoixMinMax('min','max').
ifThenChoixMinMax('max','min').

% minmax

constructionEtageMinMax([],_,[]):- !.
												  
constructionEtageMinMax(Feuilles,'min',[T|Q]) :- trouverMin6SuivantListe(6,Feuilles,FeuillesRestantes,T),
                                                 constructionEtageMinMax(FeuillesRestantes,'min',Q),!.

constructionEtageMinMax(Feuilles,'max',[T|Q]) :- trouverMax6SuivantListe(6,Feuilles,FeuillesRestantes,T),
												 constructionEtageMinMax(FeuillesRestantes,'max',Q),
												 !.									
								
minMaxRecursif(1,Feuilles,Feuilles,_):- !.	
								
minMaxRecursif(NbEtages,EtageSup,Feuilles,Choix):- constructionEtageMinMax(Feuilles,Choix,Etage),
                                                NewNbEtages is NbEtages-1,
                                                ifThenChoixMinMax(Choix,NewChoix),
                                                minMaxRecursif(NewNbEtages,EtageSup,Etage,NewChoix),
                                                !.

minMax(NbEtages,Feuilles,MaxF,IndiceCaseMax):- minMaxRecursif(NbEtages,DernierEtage,Feuilles,'min'),
                                               trouverCaseMax6SuivantListe(6,DernierEtage,IndiceCaseMax,MaxF),!.
										
										
% tests 

generateurListe3Etages(L):- Nb is 6*6*6,
							gene(Nb,L).
gene(0,[]):-!.
gene(N,[T|Q]):- NewNb is N - 1,
				T is random(15),
				gene(NewNb,Q).

testTrouverCaseMax(IndiceCase, Valeur,L):-trouverCaseMax6SuivantListe(6,[5,2,3,1,4,6,9],L,IndiceCase, Valeur).	

testConstructEtage(FeuilleEtageSup):- constructionEtageMinMax([1,2,3,6,4,5,0,2,3,7,4,5],'max',FeuilleEtageSup).

testMinMaxRecursif(Etage):- generateurListe3Etages(L),
					        minMaxRecursif(3,Etage,L,'min').

doWeHaveFortyTwo(Et):- minMaxRecursif(2,Et,[1,2,3,6,4,5,0,2,3,7,4,5,1,2,3,6,4,5,0,2,3,7,4,5,1,2,3,6,4,5,0,2,3,7,4,5],'min').


/* --------------------------------------------------------- Génération de la liste dépot de toutes les feuilles à l'horizon */
%nouvelleEvaluation('min',FonctionEvaluation,GrainesRamassees,NouvelleValEvaluation):- NouvelleValEvaluation is FonctionEvaluation - GrainesRamassees,!.

nouvelleEvaluation('min',FonctionEvaluation,GrainesRamassees,NouvelleValEvaluation):- NouvelleValEvaluation is GrainesRamassees - FonctionEvaluation,!.
nouvelleEvaluation('max',FonctionEvaluation,GrainesRamassees,NouvelleValEvaluation):- NouvelleValEvaluation is FonctionEvaluation + GrainesRamassees,!.
 
generationListeFeuille(J1,J2,Hauteur,Feuilles):- score(J1,Score1),
								score(J2,Score2),
								FonctionEvaluation is Score1 - Score2,	
								simulationLargr(3,'max',J1,J2,P1,P2,FonctionEvaluation,Feuilles).
								
simulationLargr(Hauteur,6,_,_,_,_,_,_,[]):- !.
simulationLargr(0,_,_,_,_,_,_,_,[]):- !.
								
simulationLargr(Hauteur,Case,MinMax,J1,J2,P1,P2,FonctionEvaluation,[Feuilles|Feuilles1]):- Case<6,!,
						NouvelleCase is Case + 1,
						simulationLargr(Hauteur,NouvelleCase,MinMax,J1,J2,P1,P2,FonctionEvaluation,Feuilles1),!,
						simulationProfdr(Hauteur,NouvelleCase,MinMax,J1,J2,P1,P2,FonctionEvaluation,Feuilles),!.
						
						
simulationProfdr(0,_,_,_,_,_,_,Eval,Eval):- !. 

simulationProfdr(1,Case,MinMax,J1,J2,P1,P2,FonctionEvaluation,NouvelleValEvaluation):- tourPlat(J1,J2,P1,P2,P1Fin,P2Fin,Case,GrainesRamassees),!,
																	nouvelleEvaluation(MinMax,FonctionEvaluation,GrainesRamassees,NouvelleValEvaluation),!.
 
 
simulationProfdr(Hauteur,Case,MinMax,J1,J2,P1,P2,FonctionEvaluation,Feuilles):- HauteurSvte is Hauteur-1,!, 
																	ifThenChoixMinMax(MinMax,NouvMinMax),!,
																	tourPlat(J1,J2,P1,P2,P1Fin,P2Fin,Case,GrainesRamassees),!,
																	nouvelleEvaluation(MinMax,FonctionEvaluation,GrainesRamassees,NouvelleValEvaluation),!,
																	simulationLargr(HauteurSvte,0,NouvMinMax,J2,J1,P2Fin,P1Fin,NouvelleValEvaluation,Feuilles),!.
 
														
testSimu(Hauteur,Result):- simulationLargr(Hauteur,0,'max','ordi','humain',[1,1,5,1,0,4],[2,2,0,1,3,1],0,Result).

testFinal(Hauteur,Choix,Result,Indice,Valeur):- simulationLargr(Hauteur,0,'max','ordi','humain',[1,1,5,1,0,4],[2,2,0,1,3,1],0,Feuilles),!,
							flatten(Feuilles,Feuilles1),
							minMaxRecursif(Hauteur,Result,Feuilles1,Choix),
							trouverCaseMax6SuivantListe(6,Result,Indice,Valeur),!.
/* ---------------------------------------------------------Fin génération liste feuilles*/

jouer(R):- jeu('humain',Jh),
			jeu('ordi',Jo),
			score('humain',ScoreH), score('ordi',ScoreO),
			write('Votre jeu : '),write(Jh),			
			write('\nMon jeu : '),write(Jo),
			write('\nEntrez la case dans laquelle vous désirez prendre les graines\n'),
			read(CasePriseH),
			tourPlat('humain','ordi',Jh,Jo,JhApresTourH,JoApresTourH,CasePriseH,GrainesRamasseesH),
			NouvScoreH is ScoreH+GrainesRamasseesH,
			retract(score('humain',_)),assert(score('humain',NouvScoreH)),
			write('Votre jeu : '),
			write(JhApresTourH),
			write('\nMon jeu : '),
			write(JoApresTourH),
			FonctionEval is GrainesRamasseesH,
			simulationLargr(1,0,'max','ordi','humain',JoApresTourH,JhApresTourH,FonctionEval,FeuillesArbreSimu),
			flatten(FeuillesArbreSimu,FeuillesArbre),
			minMaxRecursif(1,DernierEtage,FeuillesArbre,'max'),
			trouverCaseMax6SuivantListe(6,DernierEtage,MeilleureCase,FonctionEvalMeilleureCase),
			caseAjouer(MeilleureCase,JoApresTourH,DernierEtage,CasePriseO),
			write('\nJe vais jouer '), write(CasePriseO),write('\n'),
			tourPlat('ordi','humain',JoApresTourH,JhApresTourH,JoApresTourO,JhApresTourO,CasePriseO,GrainesRamasseesO),
			write(GrainesRamasseesO),
			NouvScoreO is ScoreO+GrainesRamasseesO,
			retract(score('ordi',_)),assert(score('ordi',NouvScoreO)),
			retract(jeu('ordi',_)),retract(jeu('humain',_)),
			assert(jeu('ordi',JoApresTourO)),assert(jeu('humain',JhApresTourO)),
			write('Votre jeu : '),write(JhApresTourO), write('\tVotre score : '),write(NouvScoreH),		
			write('\nMon jeu : '),write(JoApresTourO),write('\tMon score : '),write(NouvScoreO),				
			write('\nVoulez-vous continuer? (y/n) \n'),
			read(Rep),
			ifThenContinueJeu(Rep),!.

caseAjouer(MeilleureCase,JoApresTourH,DernierEtage,MeilleureCase):- case(MeilleureCase, JoApresTourH, NbGraines),
																NbGraines\==0.

caseAjouer(MeilleureCase,JoApresTourH,DernierEtage,CasePriseO):- modifierDernierEtage(MeilleureCase,DernierEtage,NouvDernierEtage),
																trouverCaseMax6SuivantListe(6,NouvDernierEtage,NouvMeilleureCase,FevalNouvMeillreC),
																caseAjouer(NouvMeilleureCase,JoApresTourH,NouvDernierEtage,CasePriseO),!.
																
																
modifierDernierEtage(CaseInvalide,[T|Q],[T|N]):- CaseInvalide > 1,
												NouvCase is CaseInvalide-1,
												modifierDernierEtage(NouvCase,Q,N),!.
modifierDernierEtage(CaseInvalide,[T|Q],[-99|Q]).												
			
ifThenContinueJeu(Rep):- Rep=='y',!, jouer(R).
ifThenContinueJeu(Rep):- !.

testMCase(CaseAjouer):- caseAjouer(2,[1,0,5,2,0,1],[1,9,5,2,8,6],CaseAjouer).
