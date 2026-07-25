/* Imports. */

%{

open Type
open Ast.AstSyntax
%}


%token <int> ENTIER
%token <string> ID
%token RETURN
%token VIRG
%token PV
%token AO
%token AF
%token PF
%token PO
%token EQUAL
%token CONST
%token PRINT
%token IF
%token ELSE
%token WHILE
%token BOOL
%token INT
%token RAT
%token CO
%token CF
%token SLASH
%token NUM
%token DENOM
%token TRUE
%token FALSE
%token PLUS
%token MULT
%token INF
%token EOF
%token NULL
%token NEW
%token ADDR
%token STATIC

(* Type de l'attribut synthétisé des non-terminaux *)
%type <programme> prog
%type <instruction list> bloc
%type <fonction> fonc
%type <instruction> i
%type <typ> typ
%type <typ*string*expression option> param
%type <expression> e 
%type <affectable> a
%type <variable> var
%type <expression> d
(* Type et définition de l'axiome *)
%start <Ast.AstSyntax.programme> main

%%

main : lfi=prog EOF     {lfi}

prog : lv=var* lf=fonc* ID li=bloc  {Programme (lv,lf,li)}

var: STATIC t=typ n=ID EQUAL e=e PV {Static(n,t,e)}

fonc : t=typ n=ID PO lp=separated_list(VIRG,param) PF li=bloc {Fonction(t,n,lp,li)}

param : t=typ n=ID e=option(d) {(t,n,e)}

d : EQUAL e=e {e}

bloc : AO li=i* AF      {li}

a : 
| n=ID                 {Ident n}
| PO MULT a1=a PF      {Deref a1}

i :
| STATIC t=typ n=ID EQUAL e1=e PV         {StaticLocal (t,n,e1)}
| t=typ n=ID EQUAL e1=e PV          {Declaration (t,n,e1)}
| a1=a EQUAL e1=e PV                {Affectation (a1,e1)}
| CONST n=ID EQUAL e=ENTIER PV      {Constante (n,e)}
| PRINT e1=e PV                     {Affichage (e1)}
| IF exp=e li1=bloc ELSE li2=bloc   {Conditionnelle (exp,li1,li2)}
| WHILE exp=e li=bloc               {TantQue (exp,li)}
| RETURN exp=e PV                   {Retour (exp)}

typ :
| BOOL          {Bool}
| INT           {Int}
| RAT           {Rat}
| t=typ MULT    {Pointer (t)}

e : 
| n=ID PO lp=separated_list(VIRG,e) PF   {AppelFonction (n,lp)}
| CO e1=e SLASH e2=e CF   {Binaire(Fraction,e1,e2)}
| a1=a                    {Affectable a1}
| TRUE                    {Booleen true}
| FALSE                   {Booleen false}
| e=ENTIER                {Entier e}
| NUM e1=e                {Unaire(Numerateur,e1)}
| DENOM e1=e              {Unaire(Denominateur,e1)}
| PO e1=e PLUS e2=e PF    {Binaire (Plus,e1,e2)}
| PO e1=e MULT e2=e PF    {Binaire (Mult,e1,e2)}
| PO e1=e EQUAL e2=e PF   {Binaire (Equ,e1,e2)}
| PO e1=e INF e2=e PF     {Binaire (Inf,e1,e2)}
| PO exp=e PF             {exp}
| NULL                    {Null}
| PO NEW t=typ PF         {New (t)}
| ADDR n=ID               {Addr (n)}


