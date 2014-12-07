![Bike icon image (a black vector bycicle)](bike-icon-hi.png)
#The Bike programming language

Christopher Dumas

For language implementation documentation (not comprehensive in any way, just as an aid as you read the code) [go here](https://rawgit.com/christopherdumas/Bike/master/doc/_index.html)

The Bike programming language is a programming language that combines Haskell's currying, function composition, anonymous functions, and array comprehension, with Scala's packages, classes, and traits, Python's `is` and `isnt` style operators, Scheme's everything is an expression idea, Ruby's everything-is-an-object philosophy, and Go's no paren control structures, with Coffeescript's infix `if` and `unless`. It also has optional no-paren function calls, and immutable arrays are also present. This is mixed in with mixins and Java's ananymous Classes, as well as JavaScript's Objects (called hashes) and ES6's destructuring assignment. It is immutable in everything by default, but in a way that makes it fairly painless to use. 

Bike's motto is:
> Not a lot of syntax, but a lot more sugar.


Some code samples are in order:

    import Wheels #Not nesissary but gives an idea
    import Wheels into w # Aliases!
    mixin MakesSound {
      let sound = "Blarghhh"
      def make_sound = (sound + "!") * 2
    }

    mixin Attacks {
      def attack (o) {
        println o + " has been hit!"
      }
    }

    class Animal (with MakesSound) {
      let name = "Foobar"
      def name = name
      def name= (new_name) {
        println "It takes a while, but your animal finally responds to it's new name!"
        name = new_name
      }
    }
    class Dog extends Animal (with Attacks) {
      init (n_name) {
        name(n_name) # From super!
      }
    }

    let dog = Dog.new "Lad" # Parens are optional

    dog.observe_property "name" {  # Shorthand. could have also written \name -> { println "Name set to " + name }
      println "Name set to " + args @ 0
    }
    dog = "Foo" # ERROR! Variables are immutable unless you put `var` after let.

    # In Wheels.bk
    package {
      package Math {
        def Pi = 3.141592653589793
        def E  = 2.718281828459045
      }
      def each (f, a) {
        for x of a {
          f $ x
        }
        a
      }
      def map (f, a, res) {
        if a isnt [] {
          println a @ 0
          map f, a - a @ 0, res + [f $ (a @ 0)]
        } else {
          res
        }
      }
      def filter (f, a) {
        let var res = []
        for x of a {
          if f $ x {
            res = res + [x]
          }
        }
        res
      }
      def reject (f, a) {
        let var res = []
        for x of a {
          if not f $ x {
            res = res + [x]
          }
        }
        res
      }
      def Set = class {
        let var set = []
        init (array) {
          for e of (array.uniq) {
            if e isnt nil {
              set = set + [e]
            }
          }
        }

        def array = set
        def array= (new_array) {
          let new_set = new_array.uniq
          self.new new_set
        }
      }
    }
    # And much, much more!!!
## Roadmap
In the TODO.md file is our roadmap to 1.0. It will be updated every major version release. Our versioning system is like this: The whole number (the 1 in 1.0) is incremented each major, or breaking version. The decimal point is incremented by five, and normally for big, but not breaking changes, like adding new operators or shorthand syntax. The Beta version (indicated by `+b<number>`) is incremented every time a bug is fixed, or a change is being contemplated but I have not fully committed to it.

## Development
### Setting up your development environment

    $ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" # get homebrew
    $ sudo mkdir /usr/local/Cellar
    $ sudo chown -R `whoami` /usr/local
    $ brew install ruby gem
    $ sudo gem install racc
    $ sudo gem install hanna-nouveau
    $ sudo gem install colorize
    $ sudo gem install ruby-terminfo
    $ sudo gem install irbtools
    $ sudo gem install terminal-notifier
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

| Type of Commit | emoji |
| ------------- | ------------- |
| Bug fix  | :bug: :collision:  |
| Major change  | :sparkles:  |
| code refactor | :angel: |
| documentation | :notebook: |
| Partial fix/temporary hack | :lipstick: :pig: |
| Backwards compatability | :trollface: |
