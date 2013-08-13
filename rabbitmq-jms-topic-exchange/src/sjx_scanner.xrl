%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is GoPivotal, Inc.
%% Copyright (c) 2012, 2013 GoPivotal, Inc.  All rights reserved.
%% -----------------------------------------------------------------------------
%% Derived from works which were:
%% Copyright (c) 2002, 2012 Tim Watson (watson.timothy@gmail.com)
%% Copyright (c) 2012, 2013 Steve Powell (Zteve.Powell@gmail.com)
%% -----------------------------------------------------------------------------

%% This is the rule definitions file for the JMS Selector scanner.

%% -----------------------------------------------------------------------------
Definitions.

COMMA   = ,
LP      = \(
RP      = \)
PERIOD  = \.
LET     = [A-Za-z_\$]
DIG     = [0-9]
HEXDIG  = [0-9a-fA-F]
F       = {DIG}+{PERIOD}{DIG}+([Ee][-+]?{DIG}+)?
F2      = {DIG}+({PERIOD}([Ee][-+]?{DIG}+)?|[Ee][-+]?{DIG}+)
F3      = {DIG}+({PERIOD}{DIG}*)?(f|F|d|D)
HEX     = 0x{HEXDIG}+
WS      = [\000-\s]+
CMP     = (>=|<=|<>|[=><])
IDENT   = {LET}({LET}|{DIG}|{PERIOD})*
APLUS   = [-+]
AMULT   = [*/]
STRING  = '([^']|'')*'
%'                                      % editor highlighting hack

% COMMENT = /\*([^\*]|\*[^/])*\*/       % Do not (need to) support comments
% WS      = ([\000-\s]|%.*)             % Do not (need to) support line comments

% IDENT to allow periods in names (not first char)

% All keywords are case insensitive
LIKE    = [Ll][Ii][Kk][Ee]
NOT     = [Nn][Oo][Tt]
IN      = [Ii][Nn]
AND     = [Aa][Nn][Dd]
OR      = [Oo][Rr]
IS      = [Ii][Ss]
NULL    = [Nn][Uu][Ll][Ll]
BETWEEN = [Bb][Ee][Tt][Ww][Ee][Ee][Nn]
ESCAPE  = [Ee][Ss][Cc][Aa][Pp][Ee]
TRUE    = [Tt][Rr][Uu][Ee]
FALSE   = [Ff][Aa][Ll][Ss][Ee]

Rules.

{LIKE}                  : {token, {op_like,     TokenLine, like}}.
{NOT}{WS}{LIKE}         : {token, {op_like,     TokenLine, not_like}}.
{IN}                    : {token, {op_in,       TokenLine, in}}.
{NOT}{WS}{IN}           : {token, {op_in,       TokenLine, not_in}}.
{AND}                   : {token, {op_and,      TokenLine, conjunction}}.
{OR}                    : {token, {op_or,       TokenLine, disjunction}}.
{NOT}                   : {token, {op_not,      TokenLine, negation}}.
{IS}{WS}{NULL}          : {token, {op_null,     TokenLine, is_null}}.
{IS}{WS}{NOT}{WS}{NULL} : {token, {op_null,     TokenLine, not_null}}.
{BETWEEN}               : {token, {op_between,  TokenLine, between}}.
{NOT}{WS}{BETWEEN}      : {token, {op_between,  TokenLine, not_between}}.
{ESCAPE}                : {token, {escape,      TokenLine, escape}}.
{TRUE}                  : {token, {true,        TokenLine}}.
{FALSE}                 : {token, {false,       TokenLine}}.
{CMP}                   : {token, {op_cmp,      TokenLine, atomize(TokenChars)}}.
{APLUS}                 : {token, {op_plus,     TokenLine, atomize(TokenChars)}}.
{AMULT}                 : {token, {op_mult,     TokenLine, atomize(TokenChars)}}.
{IDENT}                 : {token, {ident,       TokenLine, TokenChars}}.
{STRING}                : {token, {lit_string,  TokenLine, stripquotes(TokenChars,TokenLen)}}.
{COMMA}                 : {token, {',',         TokenLine}}.
{LP}                    : {token, {'(',         TokenLine}}.
{RP}                    : {token, {')',         TokenLine}}.
{F}                     : {token, {lit_flt,     TokenLine, list_to_float(TokenChars)}}.
{F2}                    : {token, {lit_flt,     TokenLine, to_float2(TokenChars)}}.
{F3}                    : {token, {lit_flt,     TokenLine, to_float3(TokenChars)}}.
{DIG}+                  : {token, {lit_int,     TokenLine, list_to_integer(TokenChars)}}.
{HEX}                   : {token, {lit_hex,     TokenLine, list_to_integer(lists:nthtail(2,TokenChars),16)}}.
{WS}                    : skip_token.

% {COMMENT}               : skip_token.             % Do not (need to) support comments

Erlang code.
%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is GoPivotal, Inc.
%% Copyright (c) 2012, 2013 GoPivotal, Inc.  All rights reserved.
%% -----------------------------------------------------------------------------
%% Derived from works which were:
%% Copyright (c) 2002, 2012 Tim Watson (watson.timothy@gmail.com)
%% Copyright (c) 2012, 2013 Steve Powell (Zteve.Powell@gmail.com)
%% -----------------------------------------------------------------------------

%% NB: The file with this as the first header was generated by leex - DO NOT MODIFY.

%% -----------------------------------------------------------------------------

stripquotes(Cs, L) -> undouble(lists:sublist(Cs, 2, L-2), []).

undouble([],           Acc) -> lists:reverse(Acc);
undouble([$', $'| Cs], Acc) -> undouble(Cs, [$'| Acc]);
undouble([Ch    | Cs], Acc) -> undouble(Cs, [Ch|Acc]).

%% only applied to floats {F2} and {F3} which do not have a decimal point or else no following digit
to_float2(List) -> list_to_float(insertPointNought(List, [])).

to_float3(List) -> list_to_float(removeFs(List, [], false)).

removeFs([],       Acc, false) -> lists:reverse(Acc) ++ [$., $0];
removeFs([],       Acc, true ) -> lists:reverse(Acc);
removeFs([$., $f], Acc,_Seen ) -> lists:reverse(Acc) ++ [$., $0];
removeFs([$., $F], Acc,_Seen ) -> lists:reverse(Acc) ++ [$., $0];
removeFs([$., $d], Acc,_Seen ) -> lists:reverse(Acc) ++ [$., $0];
removeFs([$., $D], Acc,_Seen ) -> lists:reverse(Acc) ++ [$., $0];
removeFs([$f],     Acc, Seen ) -> removeFs([], Acc,       Seen);
removeFs([$F],     Acc, Seen ) -> removeFs([], Acc,       Seen);
removeFs([$d],     Acc, Seen ) -> removeFs([], Acc,       Seen);
removeFs([$D],     Acc, Seen ) -> removeFs([], Acc,       Seen);
removeFs([$.| Cs], Acc,_Seen ) -> removeFs(Cs, [$.| Acc], true);
removeFs([Ch| Cs], Acc, Seen ) -> removeFs(Cs, [Ch| Acc], Seen).

insertPointNought([],       Acc) -> lists:reverse(Acc);
insertPointNought([$.| Cs], Acc) -> lists:reverse(Acc) ++ [$., $0| Cs];
insertPointNought([$e| Cs], Acc) -> lists:reverse(Acc) ++ [$., $0, $e| Cs];
insertPointNought([$E| Cs], Acc) -> lists:reverse(Acc) ++ [$., $0, $e| Cs];
insertPointNought([Ch| Cs], Acc) -> insertPointNought(Cs, [Ch| Acc]).

atomize(TokenChars) -> list_to_atom(TokenChars).
