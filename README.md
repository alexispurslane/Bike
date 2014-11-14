#The Bike programming language
[Official Website](christopherdumas.github.io/Bike)


[Contact author](mailto:christopherdumas@me.com) or @christopherdumas


The Bike programming language is a programming language that combines Haskell's currying, function composition, and array comprehension. Scala's packages, classes, and traits, Python's `is` and `isnt` style operators, Scheme's everything is an expression idea, Ruby's everything-is-an-object philosophy, and Go's no paren control structures, with Coffeescript's infix `if` and `unless`. It also has optional no-paren function calls, and immutable arrays are also present. It is immutable in everything by default, but in a way that makes it fairly painless to use. 

Bike's motto is:
> Not a lot of syntax, but a lot more sugar.


Some code samples are in order:


    class Animal {
      def sound = "some strange animal sound" # define function that returns a string. This gets you computed properties and getters for free!
      def name = "some strange animal"
      def make_sound (n) {
        let result = flatten map lambda () {
          name .. " makes " .. sound # Return doctored-up string
        }, n #!ALL WHEELS STDLIB FUNCTIONS ARE WRITTEN FOR USE IN CONTIUATION-PASSING STYLE! Also, map works on everything that defines an fmap method! (sort of like haskell)
      }
    }
    class Dog with Animal {
      def sound = "Bark!" # override some stuff
      def name = "Doggie"
    }
    let dog = Dog.new # You could also use `let var` if you wanted the variable to be mutable
    dog make_sound 3 + 2  # this is the same as dog.make_sound(3.+(2)) or dog.make_sound 3.+ 2


    let array = [1, 2, 3, 4, 5, 99] unless false # Another way to write this is: `flatten [1..5, 99]`
    let fixed_count_array = (array.set 6, 6) if true
    if array isnt fixed_count_array {
      println "Ok!"
    } else {
      println "Run for the hills!!!!"
    }


## Roadmap
In the TODO.md file is our roadmap to 1.0. It will be updated every major version release. Or versioning system is like this: The whole number (the 1 in 1.0) is incremented each major, or breaking version. The decimal point is incremented by five, and normally for big, but not breaking changes, like adding new operators or shorthand syntax. The Beta version (indicated by `+b<number>`) is incremented every time a bug is fixed, or a change is being contemplated but I have not fully committed to it.

## Development
### Setting up your development environment

    $ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" # Brew
    $ sudo mkdir /usr/local/Cellar
    $ sudo chown -R `whoami` /usr/local
    $ brew install ruby gem
    $ sudo gem install racc
    $ git clone git@github.com:christopherdumas/Bike.git bike
    $ cd bike/
    $ racc grammar.y -o parser.rb
    $ # have fun!!!!

## Contribution
### Issues
Please keep issues short and to the point. Please no flaming, or arguments over preferences over syntax. If you make any changes to the syntax, check them with the author first, over email. Also, avoid adding syntax that uses obscure symbols. Also, please no OOP vs. Functional debates. Bike is supposed to make OOP and FP live together. Any debates about them should be about how to make them work together.
### Emails to author
Please keep emails to a minimum, only when concerning major changes/bugs.
### Code Style
Please use CamelCase for classes and grammar rules, snake_case for variables, and CAPS_SNAKE_CASE for symbols related to keywords or literals. Please unit test any changes made to the Interpreter class or Lexer class. Also, only comment where things are non-obvous
### Commits
Please use descriptive commits, but under 80 characters. Always use emoji.

| ------------- | ------------- |
| Bug fix  | :bug: :collision:  |
| Major change  | :sparkles:  |
| code refactor | :angel: |
| documentation | :notebook: |
| Partial fix/temporary hack | :lipstick: :pig: |
| Backwards compatability | :trollface: |
