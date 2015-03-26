class Parser
# We need to tell the parser what tokens to expect. So each type of token produced
# by our lexer needs to be declared here.
token IF
token ELSE
token ELSIF
token UNLESS
token WHILE
token FOR
token OF

token IMPORT
token INTO
token CLASS
token PRIVATE
token HASH
token ROCKET
token WITH
token MIXIN
token PACKAGE
token EXTENDS

token DEF
token INIT
token APPLY
token ARROW

token LET
token VAR

token NUMBER
token STRING
token SYMBOL
token TRUE FALSE NIL

token IDENTIFIER
token CONSTANT
token NEWLINE

# Here is the Operator Precedence Table. As presented before, it tells the parser in
# which order to parse expressions containing operators.
# This table is based on the [C and C++ Operator Precedence Table](http://en.wikipedia.org/wiki/Operators_in_C_and_C%2B%2B#Operator_precedence).
prechigh
  left  '.' '@' 'set'
  right 'not'
  left  '*' '/'
  left  '+' '-' '%'
  left  '>' '>=' '<' '<='
  left  'is' 'isnt'
  left  'and'
  left  'or'
  right '='
  left  ','
  left  '|>'
preclow

# In the following +rule+ section, we define the parsing rules.
# All rules are declared using the following format:
#
#     RuleName:
#       OtherRule TOKEN AnotherRule    { result = Node.new }
#     | OtherRule                      { ... }
#     ;
#
# In the action section (inside the +{...}+ on the right), you can do the following:
#
# * Assign to +result+ the value returned by the rule, usually a node for the AST.
# * Use +val[index of expression]+ to get the +result+ of a matched
#   expressions on the left.
rule
  # First, parsers are dumb, we need to explicitly tell it how to handle empty
  # programs. This is what the first rule does. Note that everything between +/* ... */+ is
  # a comment.
  Program:
    /* nothing */                      { result = Nodes.new([]) }
  | Expressions                        { result = val[0] }
  ;
  
  # Next, we define what a list of expressions is. Simply put, its series of expressions separated by a
  # terminator (a new line or +;+ as defined later). But once again, we need to explicitly
  # define how to handle trailing and orphans line breaks (the last two lines).
  #
  # One very powerful trick well use to define variable rules like this one
  # (rules which can match any number of tokens) is *left-recursion*. Which means we reference
  # the rule itself, directly or indirectly, on the left side **only**. This is true for the current
  # type of parser were using (LR). For other types of parsers like ANTLR (LL), its the opposite,
  # you can only use right-recursion.
  #
  # As youll see bellow, the +Expressions+ rule references +Expressions+ itself.
  # In other words, a list of expressions can be another list of expressions followed by
  # another expression.
  Expressions:
    Expression                         { result = Nodes.new(val) }
  | Expressions Terminator Expression  { result = val[0] << val[2] }
  | Expressions Terminator             { result = val[0] }
  | Terminator                         { result = Nodes.new([]) }
  ;

  # Every type of expression supported by our language is defined here.
  Expression:
    Literal
  | ArrayAccess
  | Call
  | ForOf
  | Import
  | Apply
  | Operator
  | GetLocal
  | SetLocal
  | Lambda
  | Def
  | Class
  | Hash
  | Package
  | If
  | While
  | Unless
  | Array
  | '(' Expression ')'                    { result = val[1] }
  | '(' Expression NEWLINE ')'            { result = val[1] }
  | '(' NEWLINE Expression ')'            { result = val[2] }
  | '(' NEWLINE Expression NEWLINE ')'    { result = val[2] }
  ;

  # Notice how we implement support for parentheses using the previous rule. 
  # +'(' Expression ')'+ will force the parsing of +Expression+ in its
  # entirety first. Parentheses will then be discarded leaving only the fully parsed expression.
  #
  # Terminators are tokens that can terminate an expression.
  # When using tokens to define rules, we simply reference them by their type which we defined in
  # the lexer.
  Terminator:
    NEWLINE
  | ";"
  ;
  # Literals are the hard-coded values inside the program. If you want to add support
  # for other literal types, such as arrays or hashes, this it where youd do it.
  Literal:
    NUMBER                        { result = NumberNode.new(val[0], "Number") }
  | STRING                        { result = StringNode.new(val[0], "String") }
  | TRUE                          { result = TrueNode.new }
  | FALSE                         { result = FalseNode.new }
  | NIL                           { result = NilNode.new }
  ;
  # Method calls can take three forms:
  #
  # * Without a receiver (+self+ is assumed): +method(arguments)+.
  # * With a receiver: +receiver.method(arguments)+.
  # * And a hint of syntactic sugar so that we can drop
  #   the +()+ if no arguments are given: +receiver.method+.
  #
  # Each one of those is handled by the following rule.
  Call:
    IDENTIFIER Arguments                     { result = CallNode.new(nil, val[0], val[1], false) }
  | Expression "." IDENTIFIER
      Arguments                              { result = CallNode.new(val[0], val[2], val[3], false) }
  | Expression "." IDENTIFIER                { result = CallNode.new(val[0], val[2], [], false) }
  ;

  Apply:
    IDENTIFIER APPLY Arguments        { result = ApplyNode.new(nil, val[0], val[2]) }
  | Expression APPLY Arguments        { result = ApplyNode.new(nil, val[0], val[2], true) }
  ;

  Import:
    IMPORT IDENTIFIER                 { result = ImportNode.new(nil, "#{val[1]}.bk") }
  | IMPORT IDENTIFIER INTO IDENTIFIER { result = ImportNode.new(val[3], "#{val[1]}.bk") }
  ;

  Arguments:
    "(" ")"                       { result = [] }
  | "(" ArgList ")"               { result = val[1] }
  ;

  Array:
    "[" "]"           { result = ArrayListNode.new([]) }
  | "[" ListArray "]" { result = ArrayListNode.new(val[1]) }
  ;
  ListArray:
    Expression               { result = val }
  | ListArray "," Expression { result = val[0] << val[2] }
  ;

  ArgList:
    Expression                    { result = val }
  | ArgList "," Expression        { result = val[0] << val[2] }
  ;

  Lambda:
    '{' '(' ParamList ')' ARROW Expressions '}'                    { result = LambdaNode.new(val[2], val[5], nil) }
  | '{' '(' ParamList ')' ARROW NEWLINE Expressions '}'            { result = LambdaNode.new(val[2], val[6], nil) }
  | '{' '(' ParamList ')' ARROW Expressions NEWLINE '}'                  { result = LambdaNode.new(val[2], val[5], nil) }
  | '{' '(' ParamList ')' ARROW NEWLINE Expressions NEWLINE '}'    { result = LambdaNode.new(val[2], val[6], nil) }
  | ARROW Expression                                               { result = LambdaNode.new([], val[1]) }
  ;

  ArrayAccess:
    Expression '[' Expression ']'                  { result = CallNode.new(val[0], "@", [val[2]]) }
  ;

  # In our language, like in Ruby, operators are converted to method calls.
  # So +1 + 2+ will be converted to +1.+(2)+.
  # +1+ is the receiver of the +++ method call, passing +2+
  # as an argument.
  # Operators need to be defined individually for the Operator Precedence Table to take
  # action.
  Operator:
    Expression 'or' Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression 'and' Expression            { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<|>' Expression            { result = CallNode.new(nil,  val[1], [val[0], val[2]]) }
  | Expression '|>' Expression             { result = ApplyNode.new(nil, val[2], [val[0]], true) }
  | Expression 'is' Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression 'isnt' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | 'not' Expression                       { result = CallNode.new(val[1], val[0], []) }
  | Expression '>'  Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>=' Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<'  Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<=' Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '+'  Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '%'  Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '-'  Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '*'  Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '/'  Expression             { result = CallNode.new(val[0], val[1], [val[2]]) }
  ;
  
  GetLocal:
    IDENTIFIER                    { result = GetLocalNode.new(val[0]) }
  ;
  
  SetLocal:
    LET IDENTIFIER "=" Expression             { result = SetLocalNode.new(val[1], val[3]) }
  | LET "{" ParamList "}" "=" Expression      { result = SetLocalDescNode.new(val[2], val[5]) }
  | LET "[" IDENTIFIER ":" IDENTIFIER "]" "=" Expression      { result = SetLocalAryNode.new(val[2], val[4], val[7]) }
  | Expression '.' IDENTIFIER '=' Lambda      { result = SetClassNode.new(val[0], val[2], val[4]) }
  ;

  # Our language uses indentation to separate blocks of code. But the lexer took care of all
  # that complexity for us and wrapped all blocks in +INDENT ... DEDENT+. A block
  # is simply an increment in indentation followed by some code and closing with an equivalent
  # decrement in indentation.
  # 
  # If youd like to use curly brackets or +end+ to delimit blocks instead, youd
  # simply need to modify this one rule.
  # Youll also need to remove the indentation logic from the lexer.
  Block:
    "{" Expressions "}"                   { result = val[1] }
  | "{" NEWLINE Expressions "}"           { result = val[2] }
  | "{"  "}"                              { result = val[2] }
  | "{" Expressions NEWLINE "}"           { result = val[1] }
  | "{" NEWLINE Expressions NEWLINE "}"   { result = val[2] }
  ;

  # The +def+ keyword is used for defining methods. 
  Def:
    DEF IDENTIFIER Block                                                    { result = DefNode.new(val[1], [], val[2]) }

  | DEF IDENTIFIER "=" Expression                                           { result = DefNode.new(val[1], [], val[3]) }
  | DEF IDENTIFIER "(" ParamList ")" "=" Expression                         { result = DefNode.new(val[1], val[3], val[6]) }
  | DEF IDENTIFIER
      "(" ParamList ")" Block                                               { result = DefNode.new(val[1], val[3], val[5]) }

  | PRIVATE DEF IDENTIFIER "=" Expression                                   { result = DefNode.new(val[2], [], val[4], nil, true) }
  | PRIVATE DEF IDENTIFIER "(" ParamList ")" "=" Expression                 { result = DefNode.new(val[2], val[4], val[7], nil, true) }
  | PRIVATE DEF IDENTIFIER
      "(" ParamList ")" Block                                               { result = DefNode.new(val[2], val[4], val[6], nil, true) }
  ;


  ParamList:
    /* nothing */                 { result = [] }
  | IDENTIFIER                    { result = val }
  | ParamList "," IDENTIFIER      { result = val[0] << val[2] }
  ;

  # Class definition is similar to method definition.
  # Class names are also constants because they start with a capital letter.
  Class:
    CLASS IDENTIFIER Block                                          { result = ClassNode.new(val[1], "Object", val[2], nil) }
  | CLASS IDENTIFIER EXTENDS IDENTIFIER Block                       { result = ClassNode.new(val[1], val[3], val[4], nil) }
  ;
  Hash:
    "{" NEWLINE KeyVal "}"                { result = HashNode.new(val[2]) }
  | "{" KeyVal "}"                        { result = HashNode.new(val[1]) }
  | "{" KeyVal NEWLINE "}"                { result = HashNode.new(val[1]) }
  | "{" NEWLINE KeyVal NEWLINE "}"        { result = HashNode.new(val[2]) }
  | "{" "}"                               { result = HashNode.new([]) }
  ;
  KeyVal:
    IDENTIFIER ROCKET Expression                   { result = [[val[0], val[2]]] }
  | KeyVal "," IDENTIFIER ROCKET Expression        { result = val[0] << [val[2], val[4]] }
  ;

  Package:
    PACKAGE Block                        { result = PackageNode.new(val[1]) }
  | PACKAGE IDENTIFIER Block             { result = DefNode.new(val[1], [], PackageNode.new(val[2])) }
  ;

  # Finally, +if+ is similar to +class+ but receives a *condition*.
  If:
    IF Expression Block             { result = IfNode.new(val[1], val[2], nil, nil) }
  | IF Expression Block ElseIfs     { result = IfNode.new(val[1], val[2], nil, val[3]) }
  | IF Expression Block ElseIfs ELSE Block     { result = IfNode.new(val[1], val[2], val[5], val[3]) }
  | IF Expression Block ELSE Block  { result = IfNode.new(val[1], val[2], val[4], nil) }
  | Expression IF Expression        { result = IfNode.new(val[2], val[0], nil, nil) }
  ;

  ElseIfs:
    ELSIF Expression Block         { result = [ElseIfNode.new(val[1], val[2])] }
  | ElseIfs ELSIF Expression Block { result = val[0] << ElseIfNode.new(val[2], val[3]) }
  ;

  ForOf:
    FOR "{" IDENTIFIER "," IDENTIFIER "}" OF Expression Block      { result = ForNode.new(val[2], val[4], val[7], val[8]) }
  | FOR IDENTIFIER OF Expression Block                             { result = ForNode.new(val[1], nil, val[3], val[4]) }
  ;

  Unless:
    UNLESS Expression Block            { result = UnlessNode.new(val[1], val[2]) }
  | Expression UNLESS Expression       { result = UnlessNode.new(val[2], val[0]) }
  ;
  While:
    WHILE Expression Block           { result = WhileNode.new(val[1], val[2]) }
  ;
end

# The final code at the bottom of this Racc file will be put as-is in the generated +Parser+ class.
# You can put some code at the top (+header+) and some inside the class (+inner+).
---- header
  require_relative "lexer"
  require_relative "nodes"

---- inner
  def parse(code, show_tokens=false)
    @tokens = Lexer.new.tokenize(code) # Tokenize the code using our lexer
    puts @tokens.inspect if show_tokens
    do_parse # Kickoff the parsing process
  end
  
  def next_token
    @tokens.shift
  end
