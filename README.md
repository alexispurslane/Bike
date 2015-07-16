# Bike Language

## What's it all about?
Bike is a programming language born out of my need to have a practical, yet purely functional programming language,
with a syntax that not only matches the elegance of Python, but the terseness of Swift, and the FP
bevity of Haskell.

I think that Bike does all of this. It has a fairly substantial standard library, far bigger that that of JavaScript,
but still smaller that of Haskell.

OOP is carried out in a way that stays true to functional programming, and stays out of your way when your just trying to get things done. Objects and Classes are pure, and immutable, createing a good way to encapsulate code, without the normal OOP problems.

# Install

    git clone https://github.com/christopherdumas/Bike.git
    cd Bike/
    # You might need to install ruby.
    ./configure # Install all the needed GEMs
    ./bin/bike # Get started!

# Documentation

Documentation currently resides in the github wiki [page](https://github.com/christopherdumas/Bike/wiki).

## [Version History](https://github.com/christopherdumas/Bike/releases)
### beta 9: Raptor
More bugs fixed, and (almost) total Rubocop compliance. A gigantic refactor *was* in order. Plus, some new features:
  * Algebraic Datatypes
  * Better Debuging and error information
  * Better repl formatting
Also some minor bugs were fixed:
  * Type information should be saved during currying
  * Function return type was being ignored

### beta 8: Rackoon
Fixed a lot of OOP features, added optional typing and arguments, and added other little fixes.
### beta 7: Pipe
This release adds a modest amount of new list functions, utility functions, fixes, and a website. Also, it adds a function application operator, that works like this: `Exp |> Func`, so that you could do something like:
 `1 |> add1 |> add1 |> add1 |> add1`
### beta 6: Elephant
Removed a ton of features that were unnecessary, such as:
  * Spread and rest parameters
  * Anonymous functions
  * Weird Lambda syntax (replaced by `{ (<arg ...>) -> <body> }`)
  * Mixins
  * Weird @/set array syntax (replaced by more normal array access syntax, but no setting.)
  * Mutations on classes, arrays, hashes, or packages, and mutable variable declarations
  * Added array destructuring

Now working on:
  * Argument destructuring
  * Bigger Wheels list package
  * optional typing? - I like the dynamic ruby-ishness of Bike currently, but optional typing could be useful for documentation and preventing errors


The reason for this? (1) I came back to Bike after almost a year, and realized that it had a ton of bloat. Also, most of the code was written while I had a low grade fever. Bad idea. (2) I found a sketch of a programming language in an old notebook, and decided that it was nice, and something I would want to program in, so I am working to make Bike like it.
### beta 5: Hottrix (really bad name, I know)
This release basically had every single heisenbug that could possibly happen to a language designer. I fixed them all, and updated documentation and syntax as well. On the way, I added some well-needed little tricks.
### beta 4: Watcher
This release adds:
 - Closures
 - Real computed Properties and getters (plus setters!)
 - private and public modifiers
 - `for-of`
 - `elseif`
 - Sets
 - Observers

### beta 3: Hydra
This release adds these features to the Beta 2 release:
 -  Arrow functions
 -  Destructuring assignment (for Hashes and Anonymous Classes)
 -  String Concatenation
 -  Anonymous Classes
 -  Hashes (Anonymous Classes with syntactic sugar)
 -  Rest Arguments
 -  Documented Source, with RDoc
 -  Splat Arguments
 -  Types (internal difference. No one will notice.)

### beta 2: Drabbit
This release was the first actually implemented part of Bike. For the first time, I could actually run something.
This release had:

* anonymous functions (but no closures yet)
* functions
* variables
* classes
* inheritance
* a few library functions
* extendable Number, Object, Class, and String types
* packages
* imports (RequireJS style)
* getters
* computed properties
* mixins

Also a color REPL with history, tab completion, a lexer mode, and a history list mode.

## Roadmap
### beta 10
- [x] Typealias
- [x] Better Algebraic Datatype support in the type system
- [x] Improved Algebraic Datatypes
- [ ] ~~Class and function metadata~~ I decided that this probably wasn't a great idea.
- [ ] Getting Started
- [ ] Documentation/Tutorial
- [ ] Report error Line number

### 1.0
- [ ] Another major refactor
- [ ] Code documentation (Yardoc?)
- [ ] Improve Wheels

### 1.1
- [ ] Atom, Emacs, Vim and Sublime Text syntax highlighting
- [ ] Observers
- [ ] Ratios
- [ ] Fractions

### 1.2 and Beyond!
- [ ] Publicize!
- [ ] Write a big project of some sort in Bike, to make it look more real to people
- [ ] Macros?
- [ ] Metaprogramming?
- [ ] Dynamic method/variable/class names?
- [ ] Book
- [ ] Screencasts
