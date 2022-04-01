:-module('CLIController', [
  gummyReminderLogo/0,
  initialMenu/0,
  mainMenu/0
]).

:-use_module('../util/JsonFunctions.pl').
:- set_prolog_flag('encoding', 'utf8').
:- style_check(-singleton).

gummyReminderLogo():-
  nl,
  line,
  writeln("            _______  __   __  __   __  __   __  __   __               "),
  writeln("           |       ||  | |  ||  |_|  ||  |_|  ||  | |  |              "),
  writeln("           |    ___||  | |  ||       ||       ||  |_|  |              "),
  writeln("           |   | __ |  |_|  ||       ||       ||       |              "),
  writeln("           |   ||  ||       ||       ||       ||_     _|              "),
  writeln("           |   |_| ||       || ||_|| || ||_|| |  |   |                "),
  writeln("           |_______||_______||_|   |_||_|   |_|  |___|                "),
  writeln("  ______   _______  __   __  ___  __    _  ______   _______  ______   "),
  writeln(" |   _  | |       ||  |_|  ||   ||  |  | ||      | |       ||   _  |  "),
  writeln(" |  | | | |    ___||       ||   ||   |_| ||   _   ||    ___||  | | |  "),
  writeln(" |  |_| |_|   |___ |       ||   ||       ||  | |  ||   |___ |  |_| |_ "),
  writeln(" |   __  ||    ___||       ||   ||  _    ||  |_|  ||    ___||   __  | "),
  writeln(" |  |  | ||   |___ | ||_|| ||   || | |   ||       ||   |___ |  |  | | "),
  writeln(" |__|  |_||_______||_|   |_||___||_|  |__||______| |_______||__|  |_| "), nl,
  line,
  nl.

line:- 
  repl("\u2500", 70, L),
  atomic_list_concat(L, LineStr),
  writeln(LineStr).
lineAtom(Len, R):-
  repl("\u2500", Len, L),
  atomic_list_concat(L, LineStr),
  R = LineStr.
repl(X, N, L) :-
    length(L, N),
    maplist(=(X), L).

initialMenu():-     
  nl,
  lineAtom(30, Line30Length),
  lineAtom(29, Line29Length),
  atomic_list_concat([Line30Length, " Bem-vindo ", Line29Length], BemVindo),
  writeln(BemVindo),
  writeln("\n"),
  writeln("                        Aprenda com o auxílio de\n"),
  writeln("                        cartões de memorização\n"),
  writeln("               > Pressione qualquer tecla para iniciar <\n"),
  line,
  nl.

mainMenu:- 
  nl,
  readJSON(Decks),
  maplist(getDeckName, Decks, DeckNames),
  length(DeckNames, L),
  (
    L == 0 -> MenuDecks = 'Você não possui decks';
    listDecksNamesAndIndex(1, DeckNames, IndexedNames),
    atomic_list_concat(IndexedNames, "\n", DecksList),
    atomic_concat("Seus decks:\n\n", DecksList, MenuDecks)
    
  ),
  writeln(MenuDecks),
  write("\n              [C] Criar deck  [E] Escolher deck  [S] Sair\n"),
  write("\n> O que você deseja? "),
  read(Option),
  % (
  %   Option == "C"; Option == "c" -> createDeckMenu();
  %   Option == "E"; Option == "e" -> chooseDeckMenu();
  %   Option == "S"; Option == "s" -> halt
  % ).
  string_upper(Option, OptionUpper),
  menuOptionsDeck(OptionUpper).

getDeckName(E, Out):-
  Out = E.name.

listDecksNamesAndIndex(_, [], []).
listDecksNamesAndIndex(L, [H|T], [HOut|Rest]):-
  atomic_list_concat([L, " - ", H], HOut),
  L2 is L+1,
  listDecksNamesAndIndex(L2, T, Rest).

createDeckMenu():-
  writeln("Digite o nome do deck:"),
  read(NameDeck),
  createDeck(NameDeck, []),
  mainMenu().

chooseDeckMenu():- %TODO: Menu de escolher deck
  writeln("\n> Escolha o número do deck: "),
  read(NumDeck),
  chooseDeck(NumDeck).

chooseDeck(NumDeck):-
  readJSON(Decks), length(Decks, LenDecks),
  NumDeck > 0, NumDeck =< LenDecks,
  Indice is NumDeck - 1, nth0(Indice, Decks, Deck),
  string_concat("\n<<  ", Deck.name, ParcialString),
  string_concat(ParcialString, "  >>", StringName),
  writeln(StringName),
  writeln("\n[I] Iniciar revisão  [E] Editar nome  [A] Add carta\n"),
  writeln("          [R] Remover deck   [X] Voltar"),
  write("\n> O que você deseja? "),
  read(Option),
  string_upper(Option, OptionUpper),
  menuOptionsChoosedDeck(OptionUpper), !.

chooseDeck(NumDeck):-
  writeln("\n# Número inválido #\n"),
  mainMenu().

cardsMenu(_, []):-
  readJSON(Decks)
  writeln("                 Esse deck está vazio :(\n"), 
  mainMenu().

% TODO
% cardsMenu(Deck, Cards):-
% addCardMenu(Deck):-
% removeDeckMenu(Deck):-
% addCardMenu(Deck):-

errorMenu():-
  writeln("################# Opção inválida! #################\n")

menuOptionsDeck("C") :- createDeckMenu(), !.
menuOptionsDeck("E") :- chooseDeckMenu(), !.
menuOptionsDeck("S") :- halt, !.
menuOptionsDeck(_) :- errorMenu().

menuOptionsChoosedDeck("I") :- cardsMenu(Deck, Cards), !.
menuOptionsChoosedDeck("E") :- editDeckNameMenu(), !.
menuOptionsChoosedDeck("A") :- addCardMenu(), !.
menuOptionsChoosedDeck("R") :- removeDeckMenu(), !.
menuOptionsChoosedDeck("X") :- mainMenu(), !.
menuOptionsChoosedDeck(_) :- errorMenu().


% cardsMenu:: Deck -> [Card] -> IO()
% cardsMenu deck deckCards = do
%   deckSearch <- search (name deck)
%   case (length (cards deckSearch)) == 0 of
%     True -> do
%       putStrLn putLine
%       putStrLn "              Esse deck está vazio :(           \n"
%       mainMenu
%     False -> do 
%       shuffleDeckAndSave deckSearch
%       let headCard = (head deckCards)

%       case length deckCards == 0 of
%         True -> do
%           putStrLn putLine
%           putStrLn "        Você concluiu o estudo desse deck :D      \n"
%           mainMenu
%         False -> do
%           cardQA deck headCard
%           cardsMenu deck $ tail deckCards