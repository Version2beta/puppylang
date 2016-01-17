%%% File    : puppy_scan.xrl
%%% Author  : Rob Martin
%%% Purpose : Token definitions for Puppylang.


Definitions.
D = -?[0-9]
H = [0-9a-fA-F]
U = [A-Z]
L = [a-z]
SYM = (`|~|\!|\?|@|\#|\$|\%|\\|&|_|\||¡|¢|£|¤|¥|¦|§|¨|©|ª|«|¬|®|¯|°|±|²|³|´|µ|¶|·|¸|¹|º|»|¼|½|¾|¿|×|÷)
A = ({U}|{L}|{D}|{SYM})
WS  = [\000-\s]


Rules.

'[^']*' :
  S = lists:sublist(TokenChars, 2, TokenLen - 2),
    {token, {string, TokenLine, string_gen(S)}}.

{D}+\.{D}+((E|e)(\+|\-)?{D}+)? :
  {token, {number, TokenLine, list_to_float(TokenChars)}}.

{D}+ :
  {token, {number, TokenLine, list_to_integer(TokenChars)}}.

{WS}+ :
  skip_token.

\(.*\) :
  skip_token.

\:[^;]*; :
  Chars = lists:sublist(TokenChars, 2, TokenLen - 2),
  {token, {definition, TokenLine, Chars}}.

\[[^\]]*\] :
  {token, {quoted, TokenLine, lists:sublist(TokenChars, 2, TokenLen - 2)}}.

\+ :
  {token, {'_add', TokenLine}}.

\- :
  {token, {'_subtract', TokenLine}}.

\* :
  {token, {'_multiply', TokenLine}}.

/ :
  {token, {'_divide', TokenLine}}.

\% :
  {token, {'_mod', TokenLine}}.

\^ :
  {token, {'_exponent', TokenLine}}.

< :
  {token, {'_lt', TokenLine}}.

> :
  {token, {'_gt', TokenLine}}.

= :
  {token, {'_eq', TokenLine}}.

depth :
  {token, {'depth', TokenLine}}.

drop :
  {token, {'drop', TokenLine}}.

dup :
  {token, {'dup', TokenLine}}.

swap :
  {token, {'swap', TokenLine}}.

rot :
  {token, {'rot', TokenLine}}.

tor :
  {token, {'tor', TokenLine}}.

over :
  {token, {'over', TokenLine}}.

quote :
  {token, {'quote', TokenLine}}.

call :
  {token, {'call', TokenLine}}.

error :
  {token, {'error', TokenLine}}.

{A}+ :
  {token, {word, TokenLine, list_to_atom(TokenChars)}}.


Erlang code.

string_gen([$\\|Cs]) ->
    string_escape(Cs);
string_gen([C|Cs]) ->
    [C|string_gen(Cs)];
string_gen([]) -> [].

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
