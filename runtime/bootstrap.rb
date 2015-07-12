require_relative '../lib/util.rb'
CONSTANTS = {}
CONSTANTS['Class'] = BikeClass.new('Class')
CONSTANTS['Class'].runtime_class = CONSTANTS['Class']
CONSTANTS['Object'] = BikeClass.new
CONSTANTS['Number'] = BikeClass.new('Object', 'Num')
CONSTANTS['Array'] = BikeClass.new('Object', 'Array')
CONSTANTS['String'] = BikeClass.new('Array', 'String')
CONSTANTS['Symbol'] = BikeClass.new('Object', 'Symbol')

root_self = CONSTANTS['Object'].new
RootContext = Context.new(root_self)

CONSTANTS['TrueClass'] = BikeClass.new
CONSTANTS['FalseClass'] = BikeClass.new
CONSTANTS['NilClass'] = BikeClass.new

CONSTANTS['true'] = CONSTANTS['TrueClass'].new_with_value(true, 'Bool')
CONSTANTS['false'] = CONSTANTS['FalseClass'].new_with_value(false, 'Bool')
CONSTANTS['nil'] = CONSTANTS['NilClass'].new_with_value(nil, 'Nil')

CONSTANTS['Class'].def :new do |receiver, arguments|
  new_receiver = receiver.new
  if new_receiver.runtime_class.runtime_methods['init']
    new_receiver.call('init', arguments, new_receiver)
  end
  new_receiver
end

CONSTANTS['Object'].def :'<|>' do |_, _|
end

CONSTANTS['Object'].def :observe_property do |receiver, arguments|
  receiver.observe arguments[1].ruby_value, arguments.first
  CONSTANTS['nil']
end

CONSTANTS['Object'].def :farity do |_, arguments|
  arg = arguments.first
  if arg.is_a?(BikeMethod)
    CONSTANTS['Number'].new_with_value(arg.params.length)
  elsif arg.is_a?(BikeObject) && arg.runtime_class.is_a?(BikeMethod)
    CONSTANTS['Number'].new_with_value(arg.runtime_class.params.length)
  end
end

CONSTANTS['Object'].def :println do |_, arguments|
  check_all_arguments(arguments)
  if arguments[0].ruby_value == '\\n' || arguments[0].ruby_value == '\\r'
    puts '\n'
  else
    puts arguments[0].ruby_value
  end
  arguments[0] || CONSTANTS['nil'] # We always want to return something
end
CONSTANTS['Object'].def :command do |_, arguments|
  if system(arguments.first.ruby_value)
    CONSTANTS['true']
  else
    CONSTANTS['false']
  end
end
CONSTANTS['Object'].def :wait do |_, arguments|
  sleep(arguments.first.ruby_value)
  CONSTANTS['true']
end
CONSTANTS['Object'].def :get_char do |_, _|
  begin
    system('stty raw -echo')
    str = STDIN.getc
  ensure
    system('stty -raw echo')
  end
  CONSTANTS['String'].new_with_value(if str == '\r'
                                       '\\r'
                                     elsif str == '\n'
                                       '\\n'
                                     else
                                       str
                                     end)
end

CONSTANTS['Object'].def :print do |_, arguments|
  check_all_arguments(arguments)
  if arguments[0].ruby_value == '\\n' || arguments[0].ruby_value == '\\r'
    print '\n'
  else
    print arguments[0].ruby_value
  end
  arguments[0] || CONSTANTS['nil']
end

def check_all_arguments(args)
  args.each_index do |i|
    arg = args[i]
    fail 'Nil argument at number #{i}!' unless arg
  end
end

CONSTANTS['Object'].def :call do |receiver, _|
  receiver
end
CONSTANTS['Number'].def :+ do|receiver, arguments|
  check_all_arguments(arguments)
  result = receiver.ruby_value + arguments.first.ruby_value
  CONSTANTS['Number'].new_with_value(result)
end
CONSTANTS['Number'].def :% do |receiver, arguments|
  CONSTANTS['Number'].new_with_value(receiver.ruby_value %
                                     arguments.first.ruby_value)
end
CONSTANTS['Number'].def :- do|receiver, arguments|
  check_all_arguments(arguments)
  result = receiver.ruby_value - arguments.first.ruby_value
  CONSTANTS['Number'].new_with_value(result)
end
CONSTANTS['Number'].def :< do|receiver, arguments|
  check_all_arguments(arguments)
  result = receiver.ruby_value < arguments.first.ruby_value
  CONSTANTS['Number'].new_with_value(result)
end
CONSTANTS['Number'].def :> do|receiver, arguments|
  check_all_arguments(arguments)
  result = receiver.ruby_value > arguments.first.ruby_value
  CONSTANTS['Number'].new_with_value(result)
end
CONSTANTS['Number'].def :<= do|receiver, arguments|
  check_all_arguments(arguments)
  result = receiver.ruby_value <= arguments.first.ruby_value
  CONSTANTS['Number'].new_with_value(result)
end
CONSTANTS['Number'].def :>= do|receiver, arguments|
  check_all_arguments(arguments)
  result = receiver.ruby_value >= arguments.first.ruby_value
  CONSTANTS['Number'].new_with_value(result)
end
CONSTANTS['Number'].def :* do|receiver, arguments|
  check_all_arguments(arguments)
  result = receiver.ruby_value * arguments.first.ruby_value
  CONSTANTS['Number'].new_with_value(result)
end
CONSTANTS['Number'].def :/ do|receiver, arguments|
  check_all_arguments(arguments)
  result = receiver.ruby_value / arguments.first.ruby_value
  CONSTANTS['Number'].new_with_value(result)
end

def define_is(type)
  CONSTANTS[type].def :is do|receiver, arguments|
    check_all_arguments(arguments)
    result = receiver.ruby_value == arguments.first.ruby_value
    if result
      CONSTANTS['true']
    else
      CONSTANTS['false']
    end
  end
end

def define_isnt(type)
  CONSTANTS[type].def :isnt do|receiver, arguments|
    check_all_arguments(arguments)
    result = receiver.ruby_value != arguments.first.ruby_value
    if result
      CONSTANTS['true']
    else
      CONSTANTS['false']
    end
  end
end

def define_and(type)
  CONSTANTS[type].def :and do|receiver, arguments|
    check_all_arguments(arguments)
    result = receiver.ruby_value && arguments.first.ruby_value
    if result
      CONSTANTS['true']
    else
      CONSTANTS['false']
    end
  end
end

def define_or(type)
  CONSTANTS[type].def :or do|receiver, arguments|
    check_all_arguments(arguments)
    result = receiver.ruby_value || arguments.first.ruby_value
    if result
      CONSTANTS['true']
    else
      CONSTANTS['false']
    end
  end
end

%w(Object TrueClass FalseClass Array String Number Class).each do |k|
  define_is(k)
  define_isnt(k)
  define_and(k)
  define_or(k)
end
CONSTANTS['Object'].def :not do|receiver, _|
  if !receiver.ruby_value
    CONSTANTS['true']
  else
    CONSTANTS['false']
  end
end

CONSTANTS['Array'].def :'@' do |receiver, arguments|
  (receiver.ruby_value[arguments[0].ruby_value]) || CONSTANTS['nil']
end

CONSTANTS['Array'].def :uniq do |receiver, _|
  uniq_ary = receiver.ruby_value.map(&:ruby_value).uniq
  CONSTANTS['Array'].new_with_value(uniq_ary.map do |e|
    CONSTANTS['Object'].new_with_value(e)
  end)
end

CONSTANTS['Array'].def :set do |receiver, arguments|
  clone = receiver.ruby_value.clone
  clone[arguments[0].ruby_value] = arguments[1]
  CONSTANTS['Array'].new_with_value(clone)
end
CONSTANTS['Array'].def :length do |receiver, _|
  CONSTANTS['Number'].new_with_value(receiver.ruby_value.count) ||
    CONSTANTS['nil']
end
CONSTANTS['Array'].def :+ do |receiver, arguments|
  if  arguments.first.ruby_value.is_a?(Array)
    CONSTANTS['Array'].new_with_value(receiver.ruby_value +
      arguments.first.ruby_value)
  else
    CONSTANTS['Array'].new_with_value(receiver.ruby_value + [arguments.first])
  end
end
CONSTANTS['Array'].def :* do |receiver, arguments|
  CONSTANTS['Array'].new_with_value(receiver.ruby_value *
    arguments.first.ruby_value)
end
CONSTANTS['Array'].def :- do |receiver, arguments|
  a = receiver.ruby_value.clone
  rem = arguments.first
  a.delete_at(a.map(&:ruby_value).index(rem.ruby_value) || a.length)

  CONSTANTS['Array'].new_with_value(a)
end
CONSTANTS['Array'].def :/ do |receiver, arguments|
  na = []
  (receiver.ruby_value.length * arguments.first.ruby_value).times do ||
    na << CONSTANTS['Array'].new_with_value(
      receiver.ruby_value.slice!(0,
                                 arguments
                                   .first
                                   .ruby_value))
  end
  na = na.delete_if { |e| e.ruby_value == [] }
  CONSTANTS['Array'].new_with_value na
end

CONSTANTS['String'].def :'@' do |receiver, arguments|
  CONSTANTS['String'].new_with_value(receiver.ruby_value[arguments[0]
    .ruby_value - 1]) || CONSTANTS['nil']
end
CONSTANTS['String'].def :+ do |receiver, arguments|
  CONSTANTS['String'].new_with_value(receiver.ruby_value +
                                     arguments.first.ruby_value)
end
CONSTANTS['String'].def :* do |receiver, arguments|
  CONSTANTS['String'].new_with_value(receiver.ruby_value *
                                     arguments.first.ruby_value)
end
CONSTANTS['String'].def :- do |receiver, arguments|
  CONSTANTS['String'].new_with_value(
    receiver.ruby_value.gsub(arguments.first.ruby_value, ''))
end
CONSTANTS['String'].def :/ do |receiver, arguments|
  ns = []
  (receiver.ruby_value.length * arguments.first.ruby_value).times do ||
    ns << CONSTANTS['Array'].new_with_value(
      receiver.ruby_value.slice!(0,
                                 arguments
                                   .first
                                   .ruby_value))
  end
  ns = ns.delete_if { |e| e.ruby_value == '' }
  CONSTANTS['String'].new_with_value ns
end
