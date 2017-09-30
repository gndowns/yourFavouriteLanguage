/* Parses ocaml variable declarations */

// lexical grammar

%lex

%%
[0-9]             return 'NUMBER';
[a-zA-Z]          return 'ALPHA';
"="               return '=';
"%"           return 'PRINT';
\n\s*             return '\n';
[^\S\n]+          // ignore whitespace other than newlines
<<EOF>>           return 'EOF';

/lex

// language grammar
%%

// ocaml-list-like recursive structure
input:
    %empty
  | input line
  ;

line:
    EOF
      { return $1; }
  | '\n'
  | expr '\n'
  ;

expr:
    NUMBER
      {$$ = $1;}
  // variable assignment
  | ALPHA '=' NUMBER
      {$$ = $3}
  | PRINT ALPHA
      { console.log($2); }
  ;
