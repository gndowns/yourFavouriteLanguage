/* Parses ocaml variable declarations */

// lexical grammar

%lex

%%
\s+               // skip whitespace
[0-9]             return 'NUMBER';
<<EOF>>           return 'EOF';

/lex

// language grammar
%%

expressions
  : e EOF
    {console.log($1); return $1;}
  ;

e :
  NUMBER
    {$$ = $1;}
  ;
