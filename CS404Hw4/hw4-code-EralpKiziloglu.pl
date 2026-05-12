%----------------------------------------------------------------------
% GENE.PRO - genealogical relationships
%
%
% A Prolog database of relations derived from basic information about
% individuals.  The relations ships can all be read as 'relationship
% of', so for example, parent(P,C) means P is parent of C.
%
% When there is a performance trade-of in the implementation of a rule,
% it is assumed that in general the second argument of a relation will
% most likely be bound.  See for example full_sibling/2, which will
% have a smaller search for full_sibling(X,joe), than full_sibling(joe,X).
%
% This code is used as an example of an embedded Prolog application
% in both the directories APISAMP\WGENE and APISAMP\WGENEVB.
% One is a C++ application and the other Visual Basic.
%
% To use this code from Prolog, consult it in the listener and use the
% following predicates:
%
% open(F) - opens a file of family relationships, ex. open('england.fam').
%    open/1 just does a consult, so you can use consult instead.
% close - retracts all the persons currently defined
% save(F) - saves the persons in the named file
% add_person(Name, Mother, Father, Gender, Spouse) - adds a person
%     fact with the specified attributes, checking semantics as it does
% Relationship(P1, P2) - any relationship query, such as child(X,Y).
% relation(R, P1, P2) - can be used to find the relationship between
%     individuals as well as pose relationship queries.

%TO-LEARN: Why do we have this?
:- dynamic person/5.

parent(P,C) :-
 (mother(P,C) ; father(P,C)).

child(C,P) :- parent(P,C).

son(C,P) :- parent(P,C), male(C).

daughter(C,P) :- parent(P,C), female(C).

wife(W,P) :-
  spouse(W,P),
  female(W).

husband(H,P) :-
  spouse(H,P),
  male(H).

ancestor(A,P) :-
  parent(A,P).
ancestor(A,P) :-
  parent(X,P),
  ancestor(A,X).

descendent(D,P) :-
  parent(P,D).
descendent(D,P) :-
  parent(P,X),
  descendent(D,X).

full_sibling(S1, S2) :-
  mother(M,S2),
  mother(M,S1),
  S1 \= S2,
  father(F,S1),
  father(F,S2).

half_sibling(S1, S2) :-
  mother(M,S2),
  mother(M,S1),
  S1 \= S2,
  father(F1,S1),
  father(F2,S2),
  F1 \= F2.
half_sibling(S1, S2) :-
  father(F,S2),
  father(F,S1),
  S1 \= S2,
  mother(M1,S1),
  mother(M2,S2),
  M1 \= M2.

sibling(S1, S2) :-
  full_sibling(S1,S2).
sibling(S1, S2) :-
  half_sibling(S1,S2).

sister(S,P) :-
  sibling(S,P),
  female(S).

brother(B,P) :-
  sibling(B,P),
  male(B).

step_sibling(S1, S2) :-
  parent(P2, S2),
  spouse(M2, P2),
  parent(M2, S1),
  \+(parent(M2,S2)),
  \+(half_sibling(S1,S2)).

uncle(U,X) :-
  parent(P,X),
  brother(U,P).

aunt(A,X) :-
  parent(P,X),
  sister(A,P).

step_parent(P2,C) :-
  parent(P,C),
  spouse(P2,P),
  \+(parent(P2,C)).

step_mother(M,C) :- step_parent(M,C), female(M).

step_father(F,C) :- step_parent(F,C), male(F).

step_child(C2,P) :- step_parent(P,C2).

step_daughter(D,P) :- step_child(D,P), female(D).

step_son(S,P) :- step_child(S,P), male(S).

nephew(N,X) :-
  sibling(S,X),
  parent(S,N),
  male(N).

niece(N,X) :-
  sibling(S,X),
  parent(S,N),
  female(N).

cousin(X,Y) :-
  parent(P,Y),
  sibling(S,P),
  parent(S,X).

grandmother(GM,X) :-
  parent(P,X),
  mother(GM,P).

grandfather(GF,X) :-
  parent(P,X),
  father(GF,P).

grandparent(GP,X) :-
  parent(P,X),
  parent(GP,P).

grandson(GS,X) :-
  grandchild(GS,X),
  male(GS).

granddaughter(GD,X) :-
  grandchild(GD,X),
  female(GD).

grandchild(GC,X) :-
  parent(X,C),
  parent(C,GC).

%%%%%%%%%%%%%%%%%%ADD NEW PREDICATES HERE %%%%%%%%%%%
%TO-COMPLETE

% hala - paternal aunt (father's sister)
% X is hala of Y if X is the sister of Y's father
hala(X,Y) :-
    father(F,Y),
    sister(X,F).

% teyze - maternal aunt (mother's sister)
% X is teyze of Y if X is the sister of Y's mother
teyze(X,Y) :-
    mother(M,Y),
    sister(X,M).

% dayi - maternal uncle (mother's brother)
% X is dayi of Y if X is the brother of Y's mother
dayi(X,Y) :-
    mother(M,Y),
    brother(X,M).

% amca - paternal uncle (father's brother)
% X is amca of Y if X is the brother of Y's father
amca(X,Y) :-
    father(F,Y),
    brother(X,F).

% anneanne - maternal grandmother (mother's mother)
% X is anneanne of Y if X is the mother of Y's mother
anneanne(X,Y) :-
    mother(M,Y),
    mother(X,M).

% babaanne - paternal grandmother (father's mother)
% X is babaanne of Y if X is the mother of Y's father
babaanne(X,Y) :-
    father(F,Y),
    mother(X,F).

% gelin - daughter-in-law
% X is gelin of Y if X is married to Y's son
gelin(X,Y) :-
    son(S,Y),
    spouse(X,S),
    female(X).

% damat - son-in-law
% X is damat of Y if X is married to Y's daughter
damat(X,Y) :-
    daughter(D,Y),
    spouse(X,D),
    male(X).

% torun - grandchild
% X is torun of Y if X is a grandchild of Y
torun(X,Y) :-
    grandchild(X,Y).

% dunur - in-law relationship between parents of married couple
% X and Y are dunur if a child of X is married to a child of Y
dunur(X,Y) :-
    parent(X,C1),
    parent(Y,C2),
    spouse(C1,C2),
    X \= Y.

% list_all_married_couples - prints all married couples once
% Uses alphabetical ordering to avoid printing each pair twice
list_all_married_couples :-
    spouse(X,Y),
    X @< Y,
    write(X), write(' - '), write(Y), nl,
    fail.
list_all_married_couples.

%%%%%%%%%%%%%%%%%%ADD NEW PREDICATES HERE %%%%%%%%%%%


%----------------------------------------------------------------------
% relation/3 - used to find relationships between individuals
%

relations([parent, wife, husband, ancestor, descendent, full_sibling,
    half_sibling, sibling, sister, brother, step_sibling, uncle,
    aunt, mother, father, child, son, daughter, step_parent,
    step_child, step_mother, step_father, step_son, step_daughter,
    nephew, niece, cousin, grandmother, grandfather, grandparent,
    grandson, granddaughter, grandchild]).

relation(R, X, Y) :-
  relations(Rs),
  member(R,Rs),
  Q =.. [R,X,Y],
  call(Q).


%----------------------------------------------------------------------
% person object
%
% These predicates define the interface to a person.  All of the
% genealogical rules are based on these predicates, which are
% based on the basic representation of a person.  These are the
% only rules which need to be changed if the representation of
% a person is changed.
%
% The current representation is flat database relations of the form:
%   person(Name, Gender, Mother, Father, Spouse).
%

person(X) :-
  person(X,_,_,_,_).

male(X) :-
  person(X,male,_,_,_).

female(Y) :-
  person(Y,female,_,_,_).

mother(M,C) :-
  person(C,_,M,_,_).

father(F,C) :-
  person(C,_,_,F,_).

spouse(S,P) :-
  person(P,_,_,_,S),
  S \= single.



%---------------------------------------------------------------------------

add(Name,Gender,Mother,Father,Spouse) :-
  assert(person(Name,Gender,Mother,Father,Spouse)).

%TO-LEARN: Why do we have this code below, here?
add(Name,_,_,_,_) :-
  delete(Name),
  fail.

close :-
  retractall(person(_,_,_,_,_)).

delete(X) :-
  retract(person(X,_,_,_,_)).


%----------------------------------------------------------------------
% Semantic Integrity Checks on Update
%

%TO-LEARN: Can we move the add*( predicate at the end?
add_person(Name,Gender,Mother,Father,Spouse) :-
  retractall(message(_)),
  dup_check(Name),
  add(Name,Gender,Mother,Father,Spouse),
  ancestor_check(Name),
  mother_check(Name, Gender, Mother),
  father_check(Name, Gender, Father).

%TO-LEARN:Can we change the order of the two dup_check() predicates.
%dup_check(.) clauses?
dup_check(Name) :-
  person(Name),
  assert(message("Person is already in database")),
  !, fail.
dup_check(_).

ancestor_check(Name) :-
  ancestor(Name,Name),
  assert(message("Person is their own ancestor/descendent")),
  !, fail.
ancestor_check(_).

%TO-LEARN: Understand what mother_check does and how it works.
mother_check(_, _, Mother) :- \+(person(Mother)), !.
mother_check(_, _, Mother) :-
  male(Mother),
  assert(message("Person's mother is a man")),
  !, fail.
mother_check(Name, male, _) :-
  mother(Name, _),
  assert(message("Person, a male, is someone's mother")),
  !, fail.
mother_check(_,_,_).


father_check(_, _, Father) :- \+(person(Father)), !.
father_check(_, _, Father) :-
  female(Father),
  assert(message("Person's father is a man")),
  !, fail.
father_check(Name, female, _) :-
  father(Name, _),
  assert(message("Person, a female, is someone's father")),
  !, fail.
father_check(_,_,_).


%----------------------------------------------------------------------
% Complete the given family info here
% When your program is loaded, existing persons will be retracted and
% new ones (only) will be added
% Use "unknown" for not known names, "single" to indicate no spouse

%TO-COMPLETE
% Family structure based on the given description:
% - Ayse married Ali, they have two children: Osman and Oya
% - Oya married Murat (who has a sister Mualla)
% - Mualla married Osman, they have two children: Esra and Elif
% - Murat's parents are Remzi (father) and Rukiye (mother)

:- retractall(person(_,_,_,_,_)),
   add_person(ayse,   female, unknown, unknown, ali),
   add_person(ali,    male,   unknown, unknown, ayse),
   add_person(remzi,  male,   unknown, unknown, rukiye),
   add_person(rukiye, female, unknown, unknown, remzi),
   add_person(osman,  male,   ayse,    ali,     mualla),
   add_person(oya,    female, ayse,    ali,     murat),
   add_person(murat,  male,   rukiye,  remzi,   oya),
   add_person(mualla, female, rukiye,  remzi,   osman),
   add_person(esra,   female, mualla,  osman,   single),
   add_person(elif,   female, mualla,  osman,   single).
