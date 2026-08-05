# Feather Friends 

## Overview 

Feather Friends is a complete compiler project for a custom "bird-based" programming language. It is designed to parse and process a high-level source code language called "MINI-L". This project is divided into three development phases:

- Lexical Analyzer Generation using Flex (Phase i)
- Parser Generation using Bison (Phase ii)
- Code Generation (Phase iii)

## Tools & Technologies
Below is an overview of the key tools and technologies used in this project: 
- The MINI-L language is described in detail [here.](https://www.cs.ucr.edu/~mafar001/compiler/webpages1/mini_l.html)
- A brief introduction to flex can be found [here.](http://alumni.cs.ucr.edu/~lgao/teaching/flex.html)
- For detailed information on flex [here.](https://web.archive.org/web/20210413051647/https://poincare.matf.bg.ac.rs/~aspasic/ppj/literatura/flex.pdf)
- A brief introduction to bison can be found [here.](http://alumni.cs.ucr.edu/~lgao/teaching/bison.html)
- The detailed manual for bison can be found [here.](https://www.gnu.org/software/bison/manual/)

### Language Features

| Language Feature      | Code Example |
|-----------------------|--------------|
| Variable Declaration  | egg x;       |
| Add                   | x + y        |
| Sub                   | x - y        |
| Multiply              | x * y        |
| Divide                | x / y        |
| Modulus               | x % y        |
| Less Than             | x < y        |
| Less Than Equal       | x <= y       |
| Equality              | x == y       |
| Not Equality          | x != y       |
| Greater Than          | x > y        |
| Greater Than Equal    | x >= y       |
| Write                 | squawk(x)    |
| Read                  | survey(x)    |
| Arrays                | egg [8] array|
| Comments              | \\\/ This is a comment|

### Table of Symbols

|Symbol                | Token Name   |
|----------------------|--------------|
|chirp                 | Func         |
|migrate               | Return       |
|egg                   | Int          |
|squawk                | Print        |
|survey                | Read         |
|nest                  | While        |
|fly                   | If           |
|land                  | Else         |
|roast                 | Break        |
|soar                  | Continue     |
|(                     | LeftParen    |
|)                     | RightParen   |
|{                     | LeftCurly    |
|}                     | RightCurly   |
|[                     | LeftBracket  |
|]                     | RightBracket |
|,                     | Comma        |
|;                     | Semicolon    |
|+                     | Plus         |
|-                     | Subtract     |
|*                     | Multiply     |
|/                     | Divide       |
|%                     | Modulus      |
|=                     | Assign       |
|<                     | Less         |
|<=                    | LessEqual    |
|>                     | Greater      |
|>=                    | GreaterEqual |
|==                    | Equality     |
|!=                    | NotEqual     |
|variable_name         | Ident        |
|123456789             | Num          |

### Comments

Comments can be single line comments starting with `V`. For example:

```
egg x; V This is a variable declaration.
```

## Usage
