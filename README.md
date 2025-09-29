# Nand2Tetris-Compiler-Building
This repository contains my work for Nand2Tetris Projects 7–11, where I implemented a complete Jack-to-VM compiler from scratch. These projects are part of the legendary Nand2Tetris course  — where you build a computer system from first principles, all the way from logic gates to a working operating system and compiler.

# What This Project Does

The Jack language is an object-oriented, Java-like language used in Nand2Tetris.
This repository contains my implementation of:

- A tokenizer (turning .jack source into a stream of tokens)

- A recursive descent parser (generating structured XML output)

- A symbol table manager (tracking variables, fields, and arguments with their types and indices)

- A code generator (producing stack-based VM code)

- When run, my programs take .jack files and produce .vm files that can be executed on the Nand2Tetris Virtual Machine.

# Project Structure

`lab1.ring` – VM Translator (Arithmetic & Memory)
- Reads .vm files and translates them into Hack assembly (.asm).
- Implements stack operations (push, pop) and arithmetic commands (add, sub, neg, eq, gt, lt, etc.).
- Taught me how to manipulate the stack pointer and memory segments directly at the assembly level.

`lab2.ring` – VM Translator (Program Flow & Functions)
- Extends lab1.ring to support:
- Labels, goto, and if-goto (program flow control)
- Function definitions, function calls, and returns (call stack management)
- Learned how to implement a call stack, handle function frames, and translate high-level function calls into low-level assembly.

`lab4.ring` – Jack Tokenizer & Parser
- Implements a tokenizer that reads .jack source files character by character and outputs a <tokens> XML file.
- Implements a recursive descent parser that takes tokenized input and produces a structured parse tree in XML.
- Learned about:
  - Lexical analysis (tokenizing strings, identifiers, keywords, and symbols)
  - Parsing using recursive descent techniques
  - Abstract syntax trees and grammar-driven design

`lab5.ring` – Jack-to-VM Compiler
- Combines everything: tokenizing, parsing, building symbol tables, and generating VM code.
- Tracks variables in symbol tables (for static, field, argument, and local kinds).
- Generates VM code for:
  - Expressions and operators
  - Control flow (if, else, while)
  - Function calls (with correct this/argument setup)
  - Memory access and array indexing
- Learned how to build a full compiler back-end that generates correct VM output runnable on the Nand2Tetris VM.
