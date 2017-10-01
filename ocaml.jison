/* Parses ocaml variable declarations */

// lexical grammar

%lex

// available in grammar rules
%{
  var parser = yy.parser;
%}

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

program
  : content EOF
  ;

// ocaml-list-like recursive structure
content
  : %empty
  | line content
  ;

line
  : '\n'
  | expr '\n'
  ;

expr
  : NUMBER
      {$$ = $1;}
  // variable assignment
  | ALPHA '=' NUMBER
      {$$ = $3}
  | PRINT ALPHA
      { console.log($2); }
  ;
