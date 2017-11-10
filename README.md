# ocaml-to-js
A humble ocaml-to-javascript transpiler I made to study for my [Functional Programming Course](https://www.mcgill.ca/study/2016-2017/courses/comp-302) at McGill

# USAGE

Ocaml Lex and Grammar rules are described in `ocaml.jison`, however the actual transpiler is not included here, it must be compiled with Jison.

First, install jison with:
```
npm install jison -g
```

Now you can generate the parser with:
```
jison ocaml.jison
```

_note this command must always be re-run afer any changes are made to `ocaml.jison`_

A live interpreter-style transpiler can now be run with:
```
node interpreter.js
```

Type any valid ocaml expression, ending with `;;` and the 'interpreter' will print the javascript equivalent.
