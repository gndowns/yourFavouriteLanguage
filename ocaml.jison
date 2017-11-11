/* parses ocaml to JS */


/* lexical grammar */

%lex

/* make parser available in grammar rules */
%{
  var parser = yy.parser;
%}

%%
\s+                     /* skip whitespace */

/* keywords */
"let"                   return 'LET';
"in"                    return 'IN';
"rec"                   return 'REC';

/* operators */
"="                     return '=';
"+"                     return '+';
"-"                     return '-';
"*"                     return '*';
"/"                     return '/';
"::"                    return '::';
"@"                     return '@';

"["                     return '[';
"]"                     return ']';
";"                     return ';';

/* identifiers and literals */
\d+(\.\d+)?             return 'NUMBER';
[a-z][a-zA-Z1-9']*      return 'IDENTIFIER';


/* end of input */
<<EOF>>                 return 'EOF';

/lex

/* operator precedence */
%right '='

%left '+' '-'
%left '*' '/'

/* I'm unsure if '@' is left or right associative,
but its precedence is definitely below '::' */
%left '@'
%right '::'

/* language grammar */
%%

// represents the entire ocaml 'program' given to transpile
input
  // ocaml source code, terminated with EOF
  : content EOF
    {
      var outString = yy.parser.outString;
      // reset for next input
      yy.parser.outString = '';
      return outString
    }
;

// the actual text of the ocaml input
content
  // possible empty input, return empty string
  : %empty
    { yy.parser.prepend(""); }
  // recursive list of expressions
  | expression content
    // separate expressions with newline
    { yy.parser.prepend($1 + '\n'); }
;

expression
  // variables, lists, and mathematical expressions
  : simple_expression
      { $$ = $1; }

  // non-simple expressions, listed below, include
  // variable assignments, function definitions and calls

  // variable assignment
  | LET IDENTIFIER '=' expression
      { $$ = var_assignment_str($2, $4); }
  // function definition
  | LET IDENTIFIER argument_list '=' expression
      { $$ = function_def_str($2, $3, $5); }
  // recursive function definition
  | LET REC IDENTIFIER argument_list '=' expression
      { $$ = function_def_str($3, $4, $6); }
;

simple_expression
  : primitive_type
      {$$ = $1; }

  // list
  | list
      { $$ = $1; }

  // mathematical expressions
  | simple_expression '+' simple_expression
      { $$ = math_expr_str($1, $2, $3); }
  | simple_expression '-' simple_expression
      { $$ = math_expr_str($1, $2, $3); }
  | simple_expression '*' simple_expression
      { $$ = math_expr_str($1, $2, $3); }
  | simple_expression '/' simple_expression
      { $$ = math_expr_str($1, $2, $3); }
;

simple_expression_list
  : simple_expression
  | simple_expression simple_expression_list
      { $$ = $1; }
;

// integers, floats, and identifiers (potentially) rep'ing them
primitive_type
  : IDENTIFIER
  | NUMBER
;

// a list literal (including cons and append)
list
  // list literal
  : '[' list_elements ']'
      { $$ = '[' + $2 + ']'; }

  // list cons chain terminating in identifier
  | primitive_type "::" IDENTIFIER
      { $$ = '[' + $1 + ']' + ".concat(" + $3 + ")"; }

  // list cons
  | primitive_type "::" list
      { $$ = '[' + $1 + ']' + ".concat(" + $3 + ")"; }

  // list append
  | list '@' list
      { $$ = $1 + ".concat(" + $3 + ")"; }

;

list_elements
  : %empty
      { $$ = ""; }
  | simple_expression
      { $$ = $1; }
  | simple_expression ';' list_elements
      { $$ = $1 + ", " + $3; }
;

argument_list
  : IDENTIFIER
  | IDENTIFIER argument_list
      { $$ = $1 + ', ' +  $2; }
;

%%

// utils
var math_expr_str = function(e1, operator, e2) {
  return e1 + ' ' + operator + ' ' + e2;
}

var var_assignment_str = function(identifier, val){
  return 'var ' + identifier + ' = ' + val + ';';
}

var function_def_str = function(identifier, arg_list, val) {
  return 'var ' + identifier + ' = ' +
    'function(' + arg_list + ') {\n'
      + '  return ' + val + ';\n' +
    '}'
  ;
}

parser.prepend = function(str) {
  this.outString = !this.outString ? str : str + this.outString;
}
