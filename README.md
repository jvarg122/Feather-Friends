# Feather Friends Programming Language

**Authors:** Josue Vargas, Dalton Witt, Alejandro Vargas

Feather Friends is a complete compiler for a custom "bird-based" programming language. The compiler takes Feather Friends
source code and in stages, lexes it, parses it, checks it for semantic errors, and generates
executable intermediate representation (IR) code that runs on an interpreter.

![image](https://github.com/CitrusHappy/cs-152-feather-friends/assets/36286623/56bd944e-af45-489b-b8ec-4aab9d760445)

## Project Overview

This project was divided into four development phases:

| Phase | Component | Description |
|-------|-----------|-------------|
| 1 | **Lexer** (`lexer.lex`) | Converts Feather Friends source code into a stream of tokens, detecting invalid identifiers, unrecognized symbols, and stripping comments. |
| 2 | **Parser** (`parser.y`) | Consumes the token stream and validates it against the language's grammar (functions, statements, expressions), reporting syntax errors such as unbalanced parentheses/braces or missing semicolons. |
| 3 | **Basic Code Generation** | Generates linear (non-branching) IR for variable declarations, assignments, arithmetic, arrays, function calls/parameters, and I/O. Includes semantic analysis (undeclared variables/functions, missing `main`, duplicate declarations, array/scalar type mismatches, invalid array sizes). |
| 4 | **Complex Code Generation** | Extends code generation to control flow: `while` loops, `if`/`else`, `break`/`continue` (including nested loops), by translating structured control flow into labels, conditional branches, and jumps. Also validates that `break`/`continue` only appear inside loops. |

## Tools & Technologies
Below is an overview of the key tools and technologies used in this project: 
- The MINI-L language is described in detail [here.](https://www.cs.ucr.edu/~mafar001/compiler/webpages1/mini_l.html)
- A brief introduction to flex can be found [here.](http://alumni.cs.ucr.edu/~lgao/teaching/flex.html)
- For detailed information on flex [here.](https://web.archive.org/web/20210413051647/https://poincare.matf.bg.ac.rs/~aspasic/ppj/literatura/flex.pdf)
- A brief introduction to bison can be found [here.](http://alumni.cs.ucr.edu/~lgao/teaching/bison.html)
- The detailed manual for bison can be found [here.](https://www.gnu.org/software/bison/manual/)

## Language Features

Feather Friends uses bird-themed keywords in place of traditional ones:

| Language Feature      | Code Example  |
|------------------------|--------------|
| Function Declaration  | `chirp main() { ... }` |
| Variable Declaration  | `egg x;`     |
| Return                | `migrate x;` |
| Add                   | `x + y`      |
| Sub                   | `x - y`      |
| Multiply              | `x * y`      |
| Divide                | `x / y`      |
| Modulus               | `x % y`      |
| Less Than             | `x < y`      |
| Less Than Equal       | `x <= y`     |
| Equality              | `x == y`     |
| Not Equality          | `x != y`     |
| Greater Than          | `x > y`      |
| Greater Than Equal    | `x >= y`     |
| Write                 | `squawk(x)`  |
| Read                  | `survey(x)`  |
| Arrays                | `egg [8] array;` |
| If / Else             | `fly (cond) { ... } land { ... }` |
| While Loop            | `nest (cond) { ... }` |
| Break                 | `roast;`     |
| Continue              | `soar;`      |
| Comments              | `V This is a comment` |

### Table of Symbols

| Symbol | Token Name |
|--------|------------|
| chirp   | Func |
| migrate | Return |
| egg     | Int |
| squawk  | Print |
| survey  | Read |
| nest    | While |
| fly     | If |
| land    | Else |
| roast   | Break |
| soar    | Continue |
| `(` `)` | LeftParen / RightParen |
| `{` `}` | LeftCurly / RightCurly |
| `[` `]` | LeftBracket / RightBracket |
| `,`     | Comma |
| `;`     | Semicolon |
| `+` `-` `*` `/` `%` | Arithmetic operators |
| `=`     | Assign |
| `<` `<=` `>` `>=` `==` `!=` | Comparison operators |
| `variable_name` | Ident |
| `123456789` | Num |

### Comments

Comments can be single line comments starting with `V`. For example:

```
egg x; V This is a variable declaration.
```

## Compiler Architecture 

![Image](https://i.imgur.com/1zeGG4C.png)

## Example Program

```
V A simple program which adds two numbers together
V This program should output '150'

chirp main() {
  egg a;
  egg b;
  egg c;
  a = 100;
  b = 50;
  c = a + b;
  squawk(c);
}
```

Compiles down to intermediate representation:

```
func main
. a
. b
. c
= a, 100
= b, 50
. __temp0__
+ __temp0__, a, b
= c, __temp0__
.> __temp0__
endfunc
```

More sample programs (covering arrays, functions, loops, branches, and semantic errors) are in
[`examples/`](examples/).

## Semantic Error Checking

The code generator detects the following semantic errors and halts compilation without emitting
any code:

- Using a variable without declaring it
- Calling an undefined function
- Missing a `main` function
- Declaring a variable more than once
- Using a scalar integer as an array (or vice versa)
- Declaring an array with size <= 0
- Using `break`/`continue` outside of a loop

## Build & Run

The compiler is implemented in C++ using [Flex](https://github.com/westes/flex) for lexical
analysis and [Bison](https://www.gnu.org/software/bison/) for parsing.

### Prerequisites

- `g++` with C++11 support
- `flex`
- `bison`

### Build

```
make
```

This builds three targets:

- `print_lexer` runs just the lexer and prints the resulting token stream
- `parser` runs the full lexer + parser + semantic analysis + code generation pipeline
- `print_parser` runs the parser and prints out the grammar productions used

### Run

```
./parser < examples/add.tt
```

### Clean

```
make clean
```

## Repository Structure

```
lexer.lex             Flex lexer specification
parser.y              Bison grammar + semantic analysis + code generation
print_lexer.lex       Lexer variant that prints out the token stream
print_parser.y        Parser variant that prints out grammar productions
examples/             Sample Feather Friends (.tt) programs and expected IR (.mil) output
Makefile              Build rules
```
