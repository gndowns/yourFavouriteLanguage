// parses ocaml to JS


// lexical grammar

%lex

// make parser available in grammar rules
%{
  var parser = yy.parser;
%}

%%
\s+                     // skip whitespace

// keywords
"let"                   return 'LET';

// operators
"="                     return '=';
"+"                     return '+';
"-"                     return '-';
"*"                     return '*';
"/"                     return '/';

// identifiers and literals
\d+(\.\d+)?             return 'NUMBER';
[a-zA-Z]+               return 'ALPHA';

// end of input
<<EOF>>                 return 'EOF';

/lex

// operator precedence
%right '='
%left '+' '-' '*' '/'

// language grammar
%%

// represents the entire ocaml 'program' given
input
  : content EOF
    {
      var outString = yy.parser.outString;
      yy.parser.outString = '';
      return outString
    }
;

// TODO: multiline expressions

// the actual text of the ocaml input
content
  : %empty
  | expression content
    { yy.parser.append($1); }
;

expression
  : NUMBER
      {$$ = $1;}
  | ALPHA
      {$$ = $1;}

  // mathematical expressions
  | expression '+' expression
      { $$ = math_expr_str($1, $2, $3); }
  | expression '-' expression
      { $$ = math_expr_str($1, $2, $3); }
  | expression '*' expression
      { $$ = math_expr_str($1, $2, $3); }
  | expression '/' expression
      { $$ = math_expr_str($1, $2, $3); }

  // variable assignment
  | LET ALPHA '=' expression
      { $$ = var_assignment_str($2, $4); }
  // function definition
  | LET ALPHA argument_list '=' expression
      { $$ = function_def_str($2, $3, $5); }
;

argument_list
  : ALPHA
  | ALPHA argument_list
      { $$ = $1 + ', ' +  $2; }
;

%%

// utils
math_expr_str = function(e1, operator, e2) {
  return e1 + ' ' + operator + ' ' + e2;
}

var_assignment_str = function(identifier, val){
  return 'var ' + identifier + ' = ' + val + ';';
}

function_def_str = function(identifier, arg_list, val) {
  return 'var ' + identifier + ' = ' +
    'function(' + arg_list + ') {\n'
      + '  return ' + val + ';\n' +
    '}'
  ;
}

parser.append = function(str) {
  this.outString = !this.outString ? str : this.outString + str;
}
