%%% File    : puppy_scan.xrl
%%% Author  : Rob Martin
%%% Purpose : Token definitions for Puppylang.

Definitions.
O = [0-7]
D = -?[0-9]
H = [0-9a-fA-F]
U = [A-Z]
L = [a-z]
SYM = (@||&|_|\||/|<|>|\.|\+|-|\*|=)
A = ({U}|{L}|{D}|{SYM})
WS  = ([\000-\s]|%.*)

% can't be atoms by themselves #$^(){}[]\?,

Rules.

\(.*\) :
  skip_token.

{D}+\.{D}+((E|e)(\+|\-)?{D}+)? :
  {token, {number, TokenLine, list_to_float(TokenChars)}}.

{D}+ :
  {token, {number, TokenLine, list_to_integer(TokenChars)}}.

\: :
  {token, {startdef, TokenLine}}.

\; :
  {token, {enddef, TokenLine}}.

\[ :
  {token, {startquote, TokenLine}}.

\] :
  {token, {endquote, TokenLine}}.

\+ :
  {token, {'_add', TokenLine}}.

\- :
  {token, {'_subtract', TokenLine}}.

\* :
  {token, {'_multiply', TokenLine}}.

/ :
  {token, {'_divide', TokenLine}}.

\^ :
  {token, {'_exponent', TokenLine}}.

< :
  {token, {'_lt', TokenLine}}.

> :
  {token, {'_gt', TokenLine}}.

= :
  {token, {'_eq', TokenLine}}.

{A}* :
  {token, {word, TokenLine, list_to_atom(TokenChars)}}.

'(\\\^.|\\.|[^'])*' :
  S = lists:sublist(TokenChars, 2, TokenLen - 2),
    {token, {string, TokenLine, string_gen(S)}}.

\.{WS} :
  {end_token, {dot, TokenLine}}.

{WS}+ :
  skip_token.

Erlang code.

string_gen([$\\|Cs]) ->
    string_escape(Cs);
string_gen([C|Cs]) ->
    [C|string_gen(Cs)];
string_gen([]) -> [].

string_escape([O1,O2,O3|S]) when
  O1 >= $0, O1 =< $7, O2 >= $0, O2 =< $7, O3 >= $0, O3 =< $7 ->
    [(O1*8 + O2)*8 + O3 - 73*$0|string_gen(S)];
string_escape([$^,C|Cs]) ->
    [C band 31|string_gen(Cs)];
string_escape([C|Cs]) when C >= $\000, C =< $\s ->
    string_gen(Cs);
string_escape([C|Cs]) ->
    [escape_char(C)|string_gen(Cs)].

escape_char($n) -> $\n;       %\n = LF
escape_char($r) -> $\r;       %\r = CR
escape_char($t) -> $\t;       %\t = TAB
escape_char($v) -> $\v;       %\v = VT
escape_char($b) -> $\b;       %\b = BS
escape_char($f) -> $\f;       %\f = FF
escape_char($e) -> $\e;       %\e = ESC
escape_char($s) -> $\s;       %\s = SPC
escape_char($d) -> $\d;       %\d = DEL
escape_char(C) -> C.
