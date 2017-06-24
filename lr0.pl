%
% Magda Wasniowska
% nr indeksu: 305964
%

%
% Wyjasnienia:
%
% W tresci zadania powiedziano, ze "Z" oraz "#"
% nie wystepuja w gramatykach dlatego:
% 1. Jako inicjujaca produkcje dodaje "Z -> znak poczatkowy"
% 2. Zamiast "." uzywanej na cwiczeniach uzywam znaku "#"
% przy generowaniu sytuacji

% A oznacz skrot dla Akumulator
% By nie pomylic liczby mnogiej od pojedynczej do tej pierwszej dodaje _List
% Sytuacja = lista produkcji, reprezentowanych identycznie jak gramatyka
% wszytsko opatrzona jest komentarzem i w wiekszosci przypadkow testowym przykladem


%
% Korzystajac z konwencji przyjetej w tresci zadania
% oprocz gramatyka(.) i prod(.) dodalam:
% 1. sytuacja(Nr,Produkcja_List)
% 2. przejscie(Z,Do,Znak)
% 3. goto(Z,Do,Nieterminal)
% 4. action(Z,Do,Terminal,shift/redukcja/akceptuj)
% 5. regula(Nr,Przejscie),
% 6. automat(Gramatyka_Nr,TabelaGoTo,TabelaAction)
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pomocne do operacji na listach
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% odwroc zadana liste
% odwrocListe([a,s,d,f,r],X).
%
odwrocListe(Lista,Wynik):-
	odwrocListe(Lista,[],Wynik).
odwrocListe([],Wynik,Wynik).
odwrocListe([Elem|Reszta],A,Wynik):-
	odwrocListe(Reszta,[Elem|A],Wynik).


%
% dla danej listy usun z niej powtarzajace sie elementy
% usunPowtorzenia([a,a,a,a,a,s,s,s,s,e,e,e,e,d],X).
%
usunPowtorzenia(Lista,Wynik):-
	usunPowtorzenia(Lista,[],Wynik).
usunPowtorzenia([],Wynik,Wynik).
usunPowtorzenia([Elem|Reszta],A,Wynik):-
	member(Elem,A),usunPowtorzenia(Reszta,A,Wynik),
	!.
usunPowtorzenia([Elem|Reszta],A,Wynik):-
	usunPowtorzenia(Reszta,[Elem|A],Wynik).


%
% dla danej listy list wybierz niepowtarzalne elementy z nich
% i zachowaj w postaci jednej listy
% niepowtarzalneElementy([[a,s,d],[a,d]],X).
%
niepowtarzalneElementy(Lista,Wynik):-
	niepowtarzalneElementy(Lista,[],Wynik).
niepowtarzalneElementy([],A,Wynik):-
	usunPowtorzenia(A,Wynik).
niepowtarzalneElementy([Elem|Reszta],A,Wynik):-
	append(Elem,A,NowyA),
	niepowtarzalneElementy(Reszta,NowyA,Wynik).


%
% polacz dwie dane listy w jedna i zapisz
% czy pierwotna lista zostala rozszerzona
% zlaczListy([a,s,d],[a,e,r,f,s,f,g,d],X,Y).
%
zlaczListy(Lista1,Lista2,Wynik,Rozszerzona):-
	zlaczListy(Lista1,Lista2,[],Wynik,nie,Rozszerzona).
zlaczListy([],Lista,A,Wynik,Rozszerzona,Rozszerzona):-
	append(Lista,A,Wynik).
zlaczListy([Elem|Reszta],Lista,A,Wynik,Rozszerzona1,Rozszerzona2):-
	member(Elem,Lista),
	!,
	zlaczListy(Reszta,Lista,A,Wynik,Rozszerzona1,Rozszerzona2).
zlaczListy([Elem|Reszta],Lista,A,Wynik,_,Rozszerzona):-
	zlaczListy(Reszta,Lista,[Elem|A],Wynik,tak,Rozszerzona).


%
% sprawdza czy wszytskie elementy listy 1 naleza do listy 2
% wszystkieNaleza([a,s,d],[a,a,a,s,s,w,w,e,w,q,w,e]).
%
wszystkieNaleza([],_).
wszystkieNaleza([Elem|Reszta],Lista):-
	member(Elem,Lista),
	!,
	wszystkieNaleza(Reszta,Lista).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% z tresci zadania
% createLR(gramatyka('E',[prod('E',[[nt('E'),'+',nt('T')],[nt('T')]]),
%	prod('T',[[id],['(',nt('E'),')']])]),Automat,Info).
%
createLR(Gramatyka,Automat,Info):-
	stworzSkladowe(Gramatyka,TabelaAction,TabelaGoTo,Info),
	Gramatyka=gramatyka(_,Produkcja_List),
	ponumerujGramatyke(Produkcja_List	,1,Gramatyka_Nr),
	decyduj(automat(Gramatyka_Nr,TabelaGoTo,TabelaAction),Automat,Info),
	!.


%
% dla danej informacji decyduje czy stworzyc automat czy nie
% decyduj([],X,konflikt("R-R")).
%
decyduj(Automat,Automat,yes).
decyduj(_,null,konflikt(_)).


%
% dla danej gramatyki tworzy tabele action, tabele goto oraz 
% komunikat jesli wystapil blad
%
stworzSkladowe(Gramatyka,TabelaAction,TabelaGoTo,Komunikat):-
	Gramatyka=gramatyka(X,Produkcja_List),
	znajdzAlfabet(Produkcja_List,Alfabet),
	dopelnijSytuacje(Produkcja_List,[prod('Z',[[#,nt(X)]])],Sytuacja),
	stworzSytuacje(Sytuacja,0,Produkcja_List,Alfabet,[sytuacja(0,Sytuacja)],
		Sytuacja_Lista,[],TabelaPrzejsc),
	stworzTabeleGoTo(TabelaPrzejsc,TabelaGoTo),
	ponumerujGramatyke([prod('Z',[[nt(X)]])|Produkcja_List],0,Gramatyka_Nr),
	stworzTabeleAction(Gramatyka_Nr,Sytuacja_Lista,TabelaPrzejsc,
		TabelaAction,Komunikat).


%
% dla danej gramatyki znajdz jej alfabet (czyli niepowtarzalne znaki)
% znajdzAlfabet([prod('E',[[nt('E'),'+',nt('T')],
%	[nt('T')]]),prod('T',[[id],['(',nt('E'),')']])],X).
%
znajdzAlfabet(Gramatyka,Wynik):-
	znajdzAlfabet(Gramatyka,[],Wynik).
znajdzAlfabet([],A,Wynik):-
	usunPowtorzenia(A,Wynik).
znajdzAlfabet([prod(Znak,Reguly)|Reszta],A,Wynik):-
	niepowtarzalneElementy(Reguly,Znak_List),
	append([nt(Znak)|Znak_List],A,NowyA),
	znajdzAlfabet(Reszta,NowyA,Wynik).

%
% znajdz zbior terminali (latwiej z tabeli przejsc niz z gramatyki bo od
% razu widzimy co jest nieterminalem czyli co mozna pominac)
% znajdzTerminale([przejscie(0,4,nt(T)),przejscie(8,3,+),przejscie(1,2,nt(E))],X).
%
znajdzTerminale(TabelaPrzejsc,Wynik):-
	znajdzTerminale(TabelaPrzejsc,[],Wynik).
znajdzTerminale([],A,Wynik):-
	usunPowtorzenia(A,Wynik).
znajdzTerminale([przejscie(_,_,nt(_))|Reszta],A,Wynik):-
	znajdzTerminale(Reszta,A,Wynik),!.
znajdzTerminale([przejscie(_,_,Znak)|Reszta],A,Wynik):-
	znajdzTerminale(Reszta,[Znak|A],Wynik).


%
% dla danej reguly sprawdza czy nalezy ona do zbioru sytuacji
% sprawdzCzy([nt('E'),'+',nt('T')],[sytuacja(2,[prod('E',[id])]),
%	sytuacja(3,[prod('E',[[nt('E'),'+',nt('T')],[nt('T')]])])],X).
%
sprawdzCzy(Regula,[sytuacja(Nr,Produkcja_List)|_],Nr):-
	wProdukcjach(Regula,Produkcja_List),!.
sprawdzCzy(Regula,[_|Reszta],Nr):-
	sprawdzCzy(Regula,Reszta,Nr).


%
% dla danej reguly sprawdza czy nalezy ona do listy produkcji
% wProdukcjach([nt('E'),'+',nt('T')],[prod('T',[[id],['(',nt('E'),')']]),
%	prod('E',[[nt('E'),'+',nt('T')],[nt('T')]])]).
%
wProdukcjach(Regula,[prod(_,Reguly)|_]):-
	member(Regula,Reguly),!.
wProdukcjach(Regula,[_|Reszta]):-
	wProdukcjach(Regula,Reszta).


%
% dla danej reguly dla konkretnego nieterminala sprawdza czy nalezy
% ona do zbioru sytuacji i zapisuje liste wszytskich do ktorych nalezy
% sprawdzCzy2(prod('E',[id]),[sytuacja(2,[prod('E',[[id]])]),
%	sytuacja(3,[prod('E',[[id],[+]])])],X).
%
sprawdzCzy2(Regula,Sytuacja_Lista,Wynik):-sprawdzCzy2(Regula,Sytuacja_Lista,[],Wynik).
sprawdzCzy2(_,[],Wynik,Wynik).
sprawdzCzy2(Regula,[sytuacja(Nr,Produkcja_List)|Reszta],A,Wynik):-
	wProdukcjach2(Regula,Produkcja_List),
	sprawdzCzy2(Regula,Reszta,[Nr|A],Wynik),
	!.
sprawdzCzy2(Regula,[_|Reszta],A,Wynik):-sprawdzCzy2(Regula,Reszta,A,Wynik).


%
% dla danej reguly dla konkretnego nieterminala 
% sprawdza czy nalezy ona do listy produkcji
% wProdukcjach2(prod('E',[nt('E'),'+',nt('T')]),[prod('T',[[id],
%	['(',nt('E'),')']]),prod('E',[[nt('E'),'+',nt('T')],[nt('T')]])]).
%
wProdukcjach2(prod(X,Regula),[prod(X,Reguly)|_]):-
	member(Regula,Reguly),!.
wProdukcjach2(Regula,[_|Reszta]):-
	wProdukcjach2(Regula,Reszta).

%
% dla danej gramatyki generuje liste ponumerowanych regul poczawszy od danej liczby
% ponumerujGramatyke([prod('E',[[nt('E'),'+',nt('T')],
%	[nt('T')]]),prod('T',[[id],['(',nt('E'),')']])],0,X).
%
ponumerujGramatyke(Gramatyka,Nr,Wynik):-
	ponumerujGramatyke(Gramatyka,Nr,[],Wynik).
ponumerujGramatyke([],_,A,Wynik):-odwrocListe(A,Wynik).
ponumerujGramatyke([prod(X,Reguly)|Reszta],Nr,A,Wynik):-
	ponumerujReguly(Reguly,Nr,WynikTmp,Ostatni),
	ponumerujGramatyke(Reszta,Ostatni,[prod(X,WynikTmp)|A],Wynik).


%
% dla danej listy regul i poczatkowego numeru nadaje im kolejne
% wartosci i zapamietuje ostatni nadany numer
% ponumerujReguly([[nt('E'),'+',nt('T')],[nt('T')]],3,X,Nr).
%
ponumerujReguly(Reguly,Nr,Wynik,Ostatni):-
	ponumerujReguly(Reguly,Nr,[],Wynik,Ostatni).
ponumerujReguly([],Nr,A,Wynik,Nr):-odwrocListe(A,Wynik).
ponumerujReguly([Regula|Reszta],Nr,A,Wynik,Ostatni):-
	NowyNr is Nr + 1,
	ponumerujReguly(Reszta,NowyNr,[regula(Nr,Regula)|A],Wynik,Ostatni).


%
% dla danej listy elementow przesun znak '#' o jedna pozycje dalej
% przesunHash(['(',#,nt('E'),')'],X).
%
przesunHash(Lista,Wynik):-
	przesunHash(Lista,[],Wynik).
przesunHash([#,Elem|Reszta],A,Wynik):-
	odwrocListe(A,NowyA),
	append(NowyA,[Elem,#|Reszta],Wynik),
	!.
przesunHash([#|Reszta],A,Wynik):-
	Reszta=[],
	odwrocListe([#|A],Wynik).
przesunHash([Elem|Reszta],A,Wynik):-
	przesunHash(Reszta,[Elem|A],Wynik).


%
% dla danej listy list wstaw znak "#" przed pierwszymi symbolami w kazdej liscie
% o ile go tam juz nie ma
% wstawHash([[nt('E'),'+',nt('T')],[nt('T')]],X).
%
wstawHash(Lista,Wynik):-
	wstawHash(Lista,[],Wynik).
wstawHash([],Wynik,Wynik).
wstawHash([[]],Wynik,[[#]|Wynik]).
wstawHash([[#|Reszta1]|Reszta2],A,Wynik):-
	wstawHash(Reszta2,[[#|Reszta1]|A],Wynik).
wstawHash([[Znak|Reszta1]|Reszta2],A,Wynik):-
	wstawHash(Reszta2,[[#,Znak|Reszta1]|A],Wynik).


%
% dla danej listy list znajdz wszytskie nieterminale (elementy postaci nt(.))
% wystepujace po znaku '#' w kazdej list i zachowaj jednej liscie
% znajdzNieterminalePoHash([[#, nt('T')], [nt('E'), #, +, nt('T')]],X).
%
znajdzNieterminalePoHash(Lista,Wynik):-
	znajdzNieterminalePoHash(Lista,[],Wynik).
znajdzNieterminalePoHash([],Wynik,Wynik).
znajdzNieterminalePoHash([Elem|Reszta],A,Wynik):-
	znajdzPierwszyZnakPoHash(Elem,nt(NT)),
	znajdzNieterminalePoHash(Reszta,[NT|A],Wynik),!.
znajdzNieterminalePoHash([_|Reszta],A,Wynik):-
	znajdzNieterminalePoHash(Reszta,A,Wynik).


%
% dla danej listy znajdz pierwszy element po znaku '#'
% znajdzPierwszyZnakPoHash(['(', nt('E'), #, ')'],X).
%
znajdzPierwszyZnakPoHash([#,Elem|_],Elem).
znajdzPierwszyZnakPoHash([_|Reszta],Wynik):-
	znajdzPierwszyZnakPoHash(Reszta,Wynik).


%
% dla danej gramatyki i nieterminala znajdz jego reguly
% znajdzReguly([prod('E',[[nt('E'),'+',nt('T')],
%	[nt('T')]]),prod('T',[[id],['(',nt('E'),')']])],'E',X).
%
znajdzReguly([prod(NT,Reguly)|_],NT,Reguly).
znajdzReguly([_|Reszta],NT,Wynik):-znajdzReguly(Reszta,NT,Wynik).


%
% dla danej gramatyki i listy nieterminali znajdz ich reguly
% i wstaw znaki '#' przed pierwszymi symbolami ich regul
% znajdzRegulyIWstawHash([prod('E',[[nt('E'),'+',nt('T')],
%	[nt('T')]]),prod('T',[[id],['(',nt('E'),')']])],['E','T'],X).
%
znajdzRegulyIWstawHash(Gramatyka,NT_List,Wynik):-
	znajdzRegulyIWstawHash(Gramatyka,NT_List,[],Wynik).
znajdzRegulyIWstawHash(_,[],Wynik,Wynik).
znajdzRegulyIWstawHash(Gramatyka,[NT|Reszta],A,Wynik):-
	znajdzReguly(Gramatyka,NT,Reguly),
	wstawHash(Reguly,RegulyZHaszami),
	znajdzRegulyIWstawHash(Gramatyka,Reszta,[prod(NT,RegulyZHaszami)|A],Wynik).


%
% dla danej gramatyki i sytuacji wygeneruj dopelnienie tej sytuacji
% dodatkowa zmienna pomocnicza mowiaca czy sytuacja zostala w ktoryms z krokow 
% rozszerzona a wiec czy wymagana jest kolejna petla na jej dopelnianie
% dopelnijSytuacje([prod('E',[[nt('E'),'+',nt('T')],[nt('T')]]),
%	prod('T',[[id],['(',nt('E'),')']])],[prod('Z',[[#,nt('E')]])],X).
%
dopelnijSytuacje(Gramatyka,Sytuacja,Wynik):-
	dopelnijSytuacje(Gramatyka,Sytuacja,[],nie,Wynik).
dopelnijSytuacje(Gramatyka,[],A,tak,Wynik):-
	dopelnijSytuacje(Gramatyka,A,[],nie,Wynik),!.
dopelnijSytuacje(_,[],Wynik,nie,Wynik):-
	!.
dopelnijSytuacje(Gramatyka,[prod(_,[])|Reszta],A,Rozszerzona,Wynik):-
	dopelnijSytuacje(Gramatyka,Reszta,A,Rozszerzona,Wynik),
	!.
dopelnijSytuacje(Gramatyka,[prod(Znak,Reguly)|Reszta],A,_,Wynik):-
	znajdzNieterminalePoHash(Reguly,NT_List),
	usunPowtorzenia(NT_List,NowaNT_List),
	znajdzRegulyIWstawHash(Gramatyka,NowaNT_List,NoweReguly),
	zlaczListy([prod(Znak,Reguly)|Reszta],A,TmpA,_),
	zlaczListy(NoweReguly,TmpA,NowyA,Rozszerzona),
	dopelnijSytuacje(Gramatyka,Reszta,NowyA,Rozszerzona,Wynik).


%
% wygeneruj produkcje jakie powstana po pojawieniu się danego znaku w danej sytuacji
% znajdzNoweProdukcje([prod('T',[[#,'(',nt('E'),')'],[#,id]]),prod('Z',[[#,nt('E')]]),
%	prod('E',[[#,nt('T')],[#,nt('E'),+,nt('T')]])],nt('E'),X).
%
znajdzNoweProdukcje(Sytuacja,Znak,Wynik):-
	znajdzNoweProdukcje(Sytuacja,Znak,[],[],Wynik).
znajdzNoweProdukcje([],_,_,Wynik,Wynik).
znajdzNoweProdukcje([prod(_,[])|Reszta],Znak,[],A,Wynik):-
	znajdzNoweProdukcje(Reszta,Znak,[],A,Wynik).
znajdzNoweProdukcje([prod(X,[])|Reszta],Znak,TmpA,A,Wynik):-
	znajdzNoweProdukcje(Reszta,Znak,[],[prod(X,TmpA)|A],Wynik),
	!.
znajdzNoweProdukcje([prod(X,[Produkcja|ResztaProdukcji])|Reszta],Znak,TmpA,A,Wynik):-
	znajdzPierwszyZnakPoHash(Produkcja,NowyZnak),
	NowyZnak=Znak,
	przesunHash(Produkcja,NowaProdukcja),
	znajdzNoweProdukcje([prod(X,ResztaProdukcji)|Reszta],Znak,[NowaProdukcja|TmpA],A,Wynik).
znajdzNoweProdukcje([prod(X,[_|ResztaProdukcji])|Reszta],Znak,TmpA,A,Wynik):-
	znajdzNoweProdukcje([prod(X,ResztaProdukcji)|Reszta],Znak,TmpA,A,Wynik),!.


%
% dla danej sytuacji poczatkowej i gramatyki wygeneruj pozostale sytaucjie 
% poprzez mozliwe przejscia, wynik to lista sytuacji (nr, sytuacje=lista produkcji)
%
stworzSytuacje(_,_,_,[],Wynik,Wynik,TabelaPrzejsc,TabelaPrzejsc).
stworzSytuacje(Sytuacja,Nr,Gramatyka,[Znak|ResztaAlfabetu],A,Wynik,TA,TabelaPrzejsc):-
	znajdzNoweProdukcje(Sytuacja,Znak,NoweProdukcje),
	\+ NoweProdukcje = [],
	dopelnijSytuacje(Gramatyka,NoweProdukcje,NowaSytuacja),
	sprawdzCzyNalezy(NowaSytuacja,A,StaryNr),
	!,
	stworzSytuacje(Sytuacja,Nr,Gramatyka,ResztaAlfabetu,A,Wynik,
		[przejscie(Nr,StaryNr,Znak)|TA],TabelaPrzejsc),!.
stworzSytuacje(Sytuacja,Nr,Gramatyka,[Znak|ResztaAlfabetu],A,Wynik,TA,TabelaPrzejsc):-
	znajdzNoweProdukcje(Sytuacja,Znak,NoweProdukcje),
	\+ NoweProdukcje = [],
	dopelnijSytuacje(Gramatyka,NoweProdukcje,NowaSytuacja),
	A = [sytuacja(Max_Nr,_)|_],
	znajdzAlfabet(Gramatyka,CalyAlfabet),
	NowyNr is Max_Nr+1,!,
	stworzSytuacje(NowaSytuacja,NowyNr,Gramatyka,CalyAlfabet,
		[sytuacja(NowyNr,NowaSytuacja)|A],WynikTmp,[przejscie(Nr,NowyNr,Znak)|TA],TmpA),
	stworzSytuacje(Sytuacja,Nr,Gramatyka,ResztaAlfabetu,WynikTmp,Wynik,TmpA,TabelaPrzejsc).
stworzSytuacje(Sytuacja,Nr,Gramatyka,[_|ResztaAlfabetu],A,Wynik,TA,TabelaPrzejsc):-
	stworzSytuacje(Sytuacja,Nr,Gramatyka,ResztaAlfabetu,A,Wynik,TA,TabelaPrzejsc).


%
% dla danej sytuacji i listy sytuacji sprawdza czy dana jest jedna z nich
% sprawdzCzyNalezy([prod(E,[[nt(T),#]])],[sytuacja(8,[prod(Z,[[nt(E),#]]),
%	prod(E,[[nt(E),#,+,nt(T)]])]),sytuacja(7,[prod(E,[[nt(T),#]])])],X).
% sprawdzCzyNalezy([prod(E,[[nt(T)]])],[sytuacja(8,[prod(Z,[[nt(E),#]]),
%	prod(E,[[nt(E),#,+,nt(T)]])]),sytuacja(7,[prod(E,[[nt(T),#]])])],X).
%
sprawdzCzyNalezy(Sytuacja,[Elem|_],Nr):-
	takieSame(Sytuacja,Elem),!,Elem=sytuacja(Nr,_).
sprawdzCzyNalezy(Sytuacja,[_|Reszta],Nr):-
	sprawdzCzyNalezy(Sytuacja,Reszta,Nr).


%
% dla danej i sytuacja(.) sprawdza czy jest jednym z jej elementow
% takieSame([prod(E,[[nt(T),#]])],sytuacja(8,[prod(Z,[[nt(E)]]),prod(E,[[nt(T)]])])).
% takieSame([prod(Z,[[nt(E)]])],sytuacja(8,[prod(Z,[[nt(E)]])])).
%
takieSame(Sytuacja,sytuacja(_,Produkcja_List)):-
	wszystkieNaleza(Sytuacja,Produkcja_List),
	wszystkieNaleza(Produkcja_List,Sytuacja).


%
% skonstruuj tabele goto wybierajac z tabeli przejsc elementy 
% odpowiadajace nieterminalom
% stworzTabeleGoTo([przejscie(0,4,id),przejscie(0,8,nt(E))],X).
%
stworzTabeleGoTo(TabelaPrzejsc,Wynik):-
	stworzTabeleGoTo(TabelaPrzejsc,[],Wynik).
stworzTabeleGoTo([],Wynik,Wynik).
stworzTabeleGoTo([przejscie(Z,Do,nt(X))|Reszta],A,Wynik):-
	stworzTabeleGoTo(Reszta,[goto(Z,Do,nt(X))|A],Wynik),
	!.
stworzTabeleGoTo([_|Reszta],A,Wynik):-
	stworzTabeleGoTo(Reszta,A,Wynik).


%
% skonstruuj tabele action wybierajac z tabeli przejsc elementy 
% odpowiadajace terminalom
%
stworzTabeleAction(Gramatyka_Nr,Sytuacja_Lista,TabelaPrzejsc,Wynik,Komunikat):-
	uzupelnijShifty(TabelaPrzejsc,NowaTabelaPrzejsc),
	Gramatyka_Nr = [X|Reszta],
	X = prod(_,[regula(_,Przejscie)]),
	append(Przejscie,[#],NowePrzejscie),
	sprawdzCzy(NowePrzejscie,Sytuacja_Lista,Nr_Sytuacji),
	znajdzTerminale(TabelaPrzejsc,Terminale),
	uzupelnijRedukcje([#|Terminale],Reszta,Sytuacja_Lista,
		[action(Nr_Sytuacji,-1,#,akceptuj)|NowaTabelaPrzejsc],Wynik,Komunikat).


%
% stworz tabele action z uzupelnionymi shiftami
% uzupelnijShifty([przejscie(0,4,id),przejscie(8,3,+),przejscie(3,5,nt(T))],X).
%
uzupelnijShifty(TabelaPrzejsc,Wynik):-
	uzupelnijShifty(TabelaPrzejsc,[],Wynik).
uzupelnijShifty([],Wynik,Wynik).
uzupelnijShifty([przejscie(_,_,nt(_))|Reszta],A,Wynik):-
	uzupelnijShifty(Reszta,A,Wynik),!.
uzupelnijShifty([przejscie(X,Y,Znak)|Reszta],A,Wynik):-
	uzupelnijShifty(Reszta,[action(X,Y,Znak,shift)|A],Wynik).


%
% dla danych wartosci Z_List, Do i listy teminali stworz kawalek tabeli 
% action dla danej redukcji
% utworzRedukcje([2,3],5,[a,b,+],X).
%
utworzRedukcje(Z_List,Do,Znak_List,Wynik):-
	utworzRedukcje(Z_List,Do,Znak_List,[],Wynik).
utworzRedukcje([],_,_,A,Wynik):-
	usunPowtorzenia(A,Wynik).
utworzRedukcje([Z|Reszta],Do,Znak_List,A,Wynik):-
	utworzJednaRedukcje(Z,Do,Znak_List,TmpA),
	append(TmpA,A,NowyA),
	utworzRedukcje(Reszta,Do,Znak_List,NowyA,Wynik).


%
% dla danych wartosci Z Do i listy teminali stworz kawalek tabeli 
% action dla danej redukcji
% utworzJednaRedukcje(2,5,[a,b,+],X).
%
utworzJednaRedukcje(Z,Do,Znak_List,Wynik):-
	utworzJednaRedukcje(Z,Do,Znak_List,[],Wynik).
utworzJednaRedukcje(_,_,[],Wynik,Wynik).
utworzJednaRedukcje(Z,Do,[Znak|Reszta],A,Wynik):-
	utworzJednaRedukcje(Z,Do,Reszta,[action(Z,Do,Znak,redukcja)|A],Wynik).


%
% dla danej listy terminali i ponumerowanej gramatyki znajdz
% wszytskie redukcje i decyduj czy kontynuowac obliczenia dalej
%
uzupelnijRedukcje(Terminale,Gramatyka_Nr,Sytuacja_Lista,TabelaPrzejsc,Wynik,Komunikat):-
	uzupelnijRedukcje(Terminale,Gramatyka_Nr,Sytuacja_Lista,TabelaPrzejsc,[],Wynik,Komunikat),!.
uzupelnijRedukcje(_,[],_,_,Wynik,Wynik,yes).
uzupelnijRedukcje(Terminale,[prod(_,[])|Reszta],Sytuacja_Lista,TabelaPrzejsc,A,Wynik,Komunikat):-
	uzupelnijRedukcje(Terminale,Reszta,Sytuacja_Lista,TabelaPrzejsc,A,Wynik,Komunikat),!.
uzupelnijRedukcje(Terminale,[prod(X,[Regula|ResztaRegul])|Reszta],
		Sytuacja_Lista,TabelaPrzejsc,A,Wynik,Komunikat):-
	Regula = regula(Nr_Reguly,Przejscie),
	append(Przejscie,[#],NowePrzejscie),
	sprawdzCzy2(prod(X,NowePrzejscie),Sytuacja_Lista,Nr_Sytuacji),
	utworzRedukcje(Nr_Sytuacji,Nr_Reguly,Terminale,NowaRedukcja),
	append(TabelaPrzejsc,A,TmpA),
	usunPowtorzenia(TmpA,TmpA2),
	dodajRedukcje(NowaRedukcja,TmpA2,NowaTabelaPrzejsc,NowyKomunikat),
	append(NowaTabelaPrzejsc,A,NowyA),
	usunPowtorzenia(NowyA,NowyA2),
	sprawdzKomunikat(NowyKomunikat,Terminale,[prod(X,ResztaRegul)|Reszta],
		Sytuacja_Lista,TabelaPrzejsc,NowyA2,Wynik,Komunikat),
	!.


%
% sprawdza jaki jest obecny komunikat i ewentualnie zakoncz prace
%
sprawdzKomunikat(konflikt(X),_,_,_,_,_,null,konflikt(X)).
sprawdzKomunikat(_,Terminale,Gramatyka_Nr,Sytuacja_Lista,
		TabelaPrzejsc,A,Wynik,Komunikat):-
	usunPowtorzenia(A,TmpA),
	uzupelnijRedukcje(Terminale,Gramatyka_Nr,Sytuacja_Lista,
		TabelaPrzejsc,TmpA,Wynik,Komunikat),
	!.


% Reduce-Reduce
% atom_codes(X,[82,101,100,117,99,101,45,82,101,100,117,99,101]).
% Shift-Reduce
% atom_codes(X,[83,104,105,102,116,45,82,101,100,117,99,101]).


%
% konflikty typu R-R lub S-R
%
dodajRedukcje(JednaRedukcja,Tabela,Wynik,Komunikat):-
	dodajRedukcje(JednaRedukcja,Tabela,[],Wynik,Komunikat).
dodajRedukcje([],Tabela,A,Wynik,yes):-
	append(Tabela,A,Wynik).
dodajRedukcje([action(X,_,_,redukcja)|_],Tabela,_,_,konflikt(Info)):-
	atom_codes(Info,[82,101,100,117,99,101,45,82,101,100,117,99,101]),
	zgrupujRedukcje(Tabela,TmpA),
	member(X,TmpA),
	!.
dodajRedukcje([action(X,_,_,redukcja)|_],Tabela,_,_,konflikt(Info)):-
	atom_codes(Info,[83,104,105,102,116,45,82,101,100,117,99,101]),
	zgrupujShifty(Tabela,TmpA),
	member(X,TmpA),
	!.
dodajRedukcje([Akcja|Reszta],Tabela,A,Wynik,Komunikat):-
	dodajRedukcje(Reszta,Tabela,[Akcja|A],Wynik,Komunikat).


%
% wybiera wiersze tabeli w ktorych sa redukcje
%
zgrupujRedukcje(Tabela,Wynik):-
	zgrupujRedukcje(Tabela,[],Wynik).
zgrupujRedukcje([],A,Wynik):-
	usunPowtorzenia(A,Wynik).
zgrupujRedukcje([action(X,_,_,redukcja)|Reszta],A,Wynik):-
	zgrupujRedukcje(Reszta,[X|A],Wynik),!.
zgrupujRedukcje([_|Reszta],A,Wynik):-
	zgrupujRedukcje(Reszta,A,Wynik).


%
% wybiera wiersze tabeli w ktorych sa shifty
%
zgrupujShifty(Tabela,Wynik):-
	zgrupujShifty(Tabela,[],Wynik).
zgrupujShifty([],A,Wynik):-
	usunPowtorzenia(A,Wynik).
zgrupujShifty([action(X,_,_,shift)|Reszta],A,Wynik):-
	zgrupujShifty(Reszta,[X|A],Wynik),!.
zgrupujShifty([_|Reszta],A,Wynik):-
	zgrupujShifty(Reszta,A,Wynik).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACCEPT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%
% z tresci zadania
%
accept(Automat,Slowo):-
	append(Slowo,[#],NoweSlowo),
	akceptuj(Automat,[0],NoweSlowo),
	!.


%
% sprawdza czy dany automat akceptuje dane slowo
%
akceptuj(automat(_,_,TabelaAction),[Z|_],[Znak|_]):-
	member(action(Z,_,Znak,akceptuj),TabelaAction),
	!.
akceptuj(automat(Gramatyka_Nr,TabelaGoTo,TabelaAction),[Z|Reszta],Slowo):-
	member(action(Z,Do,_,redukcja),TabelaAction),
	znajdzReguleONumerze(Gramatyka_Nr,Do,NT,Regula),
	ileZnakow(Regula,RegulaDlugosc),
	length(X,RegulaDlugosc),
	append(X,[Stan|NowyStos],[Z|Reszta]),
	member(goto(Stan,NowyStan,nt(NT)),TabelaGoTo),
	!,
	akceptuj(automat(Gramatyka_Nr,TabelaGoTo,TabelaAction),[NowyStan,Stan|NowyStos],Slowo),
	!.
akceptuj(automat(Gramatyka_Nr,TabelaGoTo,TabelaAction),[Z|Reszta],[Znak|ResztaZnakow]) :-
	member(action(Z,Do,Znak,shift),TabelaAction),
	!,
	akceptuj(automat(Gramatyka_Nr,TabelaGoTo,TabelaAction),[Do,Z|Reszta],ResztaZnakow),
	!.


%
% dla danej reguly przejsc okresl ile ona ma uzytych znkow
% ileZnakow([nt(A),x],X).
%
ileZnakow(Regula,Wynik):-
	ileZnakow(Regula,0,Wynik).
ileZnakow([],Wynik,Wynik).
ileZnakow([_|Reszta],A,Wynik):-
	TmpA is A + 1,
	ileZnakow(Reszta,TmpA,Wynik).


%
% dla danej ponumerowanej gramatyki znajdz regule o danym numerze
% i zapamietaj dla jakiego nieterminala ona jest
% znajdzReguleONumerze([prod('E',[regula(0,[nt('E'),+,nt('T')]),
%	regula(1,[nt('T')])]),prod('T',[regula(2,[id]),regula(3,['(',nt('E'),')'])])],2,Nt,X).
%
znajdzReguleONumerze([prod(NT,[regula(Nr,Wynik)|_])|_],Nr,NT,Wynik):-
	!.
znajdzReguleONumerze([prod(_,[])|Reszta],Nr,NT,Wynik):-
	znajdzReguleONumerze(Reszta,Nr,NT,Wynik),
	!.
znajdzReguleONumerze([prod(_,[_|Produkcje])|Reguly],Nr,NT,Wynik):-
	znajdzReguleONumerze([prod(NT,Produkcje)|Reguly],Nr,NT,Wynik).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zbuduj(NG,Komunikat):-
	grammar(NG,G),
	createLR(G,_,Komunikat).


test(NG,ListaSlow):-
	grammar(NG,G),
	createLR(G,Automat,yes),
	checkWords(ListaSlow,Automat).

checkWords([],_):-
	write('Koniec testu.\n').
checkWords([S|RS], Automat):-
	format("  Slowo: ~p ",[S]),
	(accept(Automat,S)->true; write('NIE ')),
	write('nalezy.\n'),
	checkWords(RS,Automat).

% Przykladowe gramatyki
grammar(ex1,gramatyka('E',[
	prod('E',[[nt('E'),'+',nt('T')],[nt('T')]]),
	prod('T',[[id],['(',nt('E'),')']])])).
grammar(ex2,gramatyka('A',[
	prod('A',[[nt('A'),x],[x]])])).
grammar(ex3,gramatyka('A',[
	prod('A',[[x,nt('A')],[x]])])).
grammar(ex4,gramatyka('A',[
	prod('A',[[x,nt('B')],[nt('B'),y],[]]),
	prod('B',[[]])])).
grammar(ex5,gramatyka('S',[
	prod('S',[[id],[nt('V'),':=',nt('E')]]),
	prod('V',[[id],[id,'[',nt('E'),']']]),
	prod('E',[[v]])])).
grammar(ex6,gramatyka('A',[
	prod('A',[[x],[nt('B'), nt('B')]]),
	prod('B',[[x]])])).
grammar(ex7,gramatyka('E',[
	prod('E',[[nt('E'),+,nt('E')],[nt('E'),*,nt('E')],[a]])])).
grammar(ex8,gramatyka('S',[
	prod('S',[[nt('A'),nt('B')]]),
	prod('A',[[a]]),
	prod('B',[[nt('S')],[b],[b,b]])])).
grammar(ex9,gramatyka('F',[
	prod('F',[['(',nt('L'),')']]),
	prod('L',[[nt('L'),nt('E')],[e]]),
	prod('E',[[nt('F')],[a]])])).

% zbuduj(ex1,X).
% zbuduj(ex2,X).
% zbuduj(ex3,X).
% zbuduj(ex4,X).
% zbuduj(ex5,X).
% zbuduj(ex6,X).
% zbuduj(ex7,X).
% zbuduj(ex8,X).
% zbuduj(ex9,X).


% test(ex1,[[id],['(',id,')'],[id,'+',ident],[id,'+',id]]).
% test(ex2,[[id],[x,x,x,x],[],[xA]]).
% test(ex9,[['(',e,')'],[e],[],['(',e,a,a,')'],
%	['(',a,a,a,')'],['(',e,'(',e,')','(',e,')',')']]).