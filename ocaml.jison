/* parses ocaml to JS */


/* lexical grammar */

%lex

%%
\s+                     /* skip whitespace */

/* keywords */
"let"                   return 'LET';
"in"                    return 'IN';
"rec"                   return 'REC';

/* identifiers and literals */
[a-z][a-zA-Z0-9_']*     return 'IDENTIFIER';
\d+(\.)(\d+)?           return 'FLOAT';
\d+                     return 'INTEGER';
\'[a-zA-Z]\'            return 'CHAR';
\"[a-zA-Z]+\"           return 'STRING';

/* operators */
"="                     return '=';
"+."                    return '+.';
"-."                    return '-.';
"*."                    return '*.';
"/."                    return '/.';
"+"                     return '+';
"-"                     return '-';
"*"                     return '*';
"/"                     return '/';
"::"                    return '::';
"@"                     return '@';

"("                     return '(';
")"                     return ')';
"["                     return '[';
"]"                     return ']';
";"                     return ';';


/* end of input */
<<EOF>>                 return 'EOF';

/lex

/* operator precedence */
%right '='

%left '+' '-' '+.' '-.'
%left '*' '/' '*.' '/.'

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
    { return $1; }
;

// the actual text of the ocaml input
content
  // recursive list of successive definitions (functions,
  // vars, types, etc) representing an entire program
  : definitions
  // single expression followed by EOF
  // (primarily for use in interpreter mode)
  | expression_wrapper
;

// allows us to differentiate between simple expressions and
// function calls
expression_wrapper
  : expression
  // function call
  | IDENTIFIER arguments
      { $$ = $1 + '(' + $2 + ')'; }
;


expression
  // the simplest expression, an identifier or constant literal
  : primitive_type

  // mathematical expressions
  | expression '+' expression
      { $$ = concat_str($1, $2, $3); }
  | expression '-' expression
      { $$ = concat_str($1, $2, $3); }
  | expression '*' expression
      { $$ = concat_str($1, $2, $3); }
  | expression '/' expression
      { $$ = concat_str($1, $2, $3); }
  | expression "+." expression
      { $$ = concat_str($1, $2, $3); }
  | expression "-." expression
      { $$ = concat_str($1, $2, $3); }
  | expression "*." expression
      { $$ = concat_str($1, $2, $3); }
  | expression "/." expression
      { $$ = concat_str($1, $2, $3); }
;

// the meat and potatoes of a real ocaml program
definition
  : LET let_binding
      { $$ = "var " + $2; }
;

// used for variable and function assignment
let_binding
  // var assignment
  : IDENTIFIER '=' expression_wrapper
      { $$ = $1 + " = " + $3; }
  // function assignment (ocaml functions always
  // have at least one arg)
  | IDENTIFIER parameters '=' expression_wrapper
      { $$ = function_def_str($1, $2, $4); }
  | REC IDENTIFIER parameters '=' expression_wrapper
      { $$ = function_def_str($2, $3, $5); }
;

// all primitive data types as well as variable names
primitive_type
  : IDENTIFIER
  | FLOAT
  | INTEGER
  | CHAR
  | STRING
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

// what can be given to a function
argument
  : primitive_type
  | '(' expression ')'
      { $$ = $2; }
;

// RECURSIVELY DEFINED LISTS ===============
// recurisve list of definitions
definitions
  // possible empty input, return empty string
  : %empty
      { $$ = ""; }
  | definition definitions
      { $$ = $1 + '\n' + $2; }
;


// list of parameter identifiers in function definition
parameters
  : IDENTIFIER
  | IDENTIFIER parameters
      { $$ = $1 + ', ' +  $2; }
;

// list of expressions, used as args in function call
arguments
  : argument
  | argument arguments
      { $$ = $1 + ',' + $2; }
;

%%

// utils
var concat_str = function(e1, operator, e2) {
  return e1 + ' ' + operator + ' ' + e2;
}

var function_def_str = function(identifier, arg_list, val) {
  return identifier + ' = ' +
    'function(' + arg_list + ') {\n'
      + '  return ' + val + ';\n' +
    '}'
  ;
}
