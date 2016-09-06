# The first type is responsible for holding a collection of nodes,
# each one representing an expression. You can think of it as the internal
# representation of a block of code.
#
# Here we define nodes as Ruby classes that inherit from a Struct. This is a
# simple way, in Ruby, to create a class that holds some attributes (values).
# It is almost equivalent to:
#
#     class Nodes
#       def initialize(nodes)
#         @nodes = nodes
#       end
#
#       def nodes
#         @nodes
#       end
#     end
#
#     n = Nodes.new("this is stored @nodes")
#     n.nodes # => "this is stored @nodes"
#
# But Ruby's Struct takes care of overriding the == operator for us and a bunch of
# other things that will make testing easier.
class Nodes
  attr_accessor :nodes, :line
  def initialize (nodes, line=0)
    @nodes = nodes
    @line = line
    @nodes.each { |n| n.line = @line }
  end

  def <<(node) # Useful method for adding a node on the fly.
    nodes << node
    self
  end
end

# Literals are static values that have a Ruby representation. For example, a string, a number,
# true, false, nil, etc. We define a node for each one of those and store their Ruby
# representation inside their value attribute.
class LiteralNode < Struct.new(:value, :type, :line); end

class NumberNode < LiteralNode; end

class StringNode < LiteralNode; end

class TrueNode < LiteralNode
  def initialize
    super(true, "TrueClass")
  end
end

class FalseNode < LiteralNode
  def initialize
    super(false, "TrueClass")
  end
end

class NilNode < LiteralNode
  def initialize
    super(nil, "NilClass")
  end
end

class ArrayListNode < LiteralNode; end

# The node for a method call holds the receiver,
# the object on which the method is called, the method name and its
# arguments, which are other nodes.
class CallNode < Struct.new(:receiver, :method, :arguments, :is_splat, :line); end
class ApplyNode < Struct.new(:receiver, :method, :arguments, :is_expr, :line); end
class ImportNode < Struct.new(:into, :file, :line); end

# Retrieving the value of a constant by its name is done by the following node.
class GetConstantNode < Struct.new(:name, :line); end

# Similar to the previous nodes, the next ones are for dealing with local variables.
class GetLocalNode < Struct.new(:name, :dotIdent, :line); end

class SetLocalNode < Struct.new(:name, :value, :line); end
class SetLocalDescNode < SetLocalNode; end
class SetLocalAryNode < Struct.new(:head, :tail, :array, :line); end

# Each method definition will be stored into the following node. It holds the name of the method,
# the name of its parameters (params) and the body to evaluate when the method is called, which
# is a tree of node, the root one being a Nodes instance.
class DefNode < Struct.new(:name, :params, :body, :type_ret, :line); end
class OrNode < Struct.new(:first, :second, :line); end
class AndThen < Struct.new(:first, :second, :line); end
class LambdaNode < Struct.new(:params, :body, :vararg, :line); end

# Class definitions are stored into the following node. Once again, the name of the class and
# its body, a tree of nodes.
class ClassNode < Struct.new(:name, :superclass, :body, :mixins, :line); end
class DataNode < Struct.new(:name, :types, :line); end
class TypeAliasNode < Struct.new(:talias, :type, :line); end
class SetClassNode < Struct.new(:bike_class, :method, :lambda, :line); end
class HashNode < Struct.new(:key_values, :line); end
class PackageNode < Struct.new(:body, :line); end

# if control structures are stored in a node of their own. The condition and body will also
# be nodes that need to be evaluated at some point.
# Look at this node if you want to implement other control structures like while, for, loop, etc.
class IfNode < Struct.new(:condition, :body, :else_body, :elseifs, :line); end
class ElseIfNode < Struct.new(:condition, :body, :line); end
class ForNode < Struct.new(:key, :value, :iterator, :body, :line); end

class UnlessNode < Struct.new(:condition, :body, :line); end

class WhileNode < Struct.new(:condition, :body, :line); end
