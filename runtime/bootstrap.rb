Constants = {}
Constants["Class"] = BikeClass.new # Defining the `Class` class.
Constants["Class"].runtime_class = Constants["Class"] # Setting `Class.class = Class`.
Constants["Object"] = BikeClass.new # Defining the `Object` class
Constants["Number"] = BikeClass.new(Constants["Object"]) # Defining the `Number` class
Constants["Array"] = BikeClass.new(Constants["Object"]) # Defining the `Array` class
Constants["String"] = BikeClass.new(Constants["Array"])

root_self = Constants["Object"].new
RootContext = Context.new(root_self)

Constants["TrueClass"] = BikeClass.new
Constants["FalseClass"] = BikeClass.new
Constants["NilClass"] = BikeClass.new

Constants["true"] = Constants["TrueClass"].new_with_value(true)
Constants["false"] = Constants["FalseClass"].new_with_value(false)
Constants["nil"] = Constants["NilClass"].new_with_value(nil)

Constants["Class"].def :new do |receiver,arguments|
  receiver.new
end
Constants["Object"].def :println do |receiver, arguments|
  puts arguments.first.ruby_value
  arguments[0] || Constants["nil"] # We always want to return objects from our runtime
end
Constants["Object"].def :println_all do |receiver, arguments|
  arguments.foreach do |e|
    puts e.ruby_value
  end
  arguments || Constants["nil"] # We always want to return objects from our runtime
end
Constants["Object"].def :print do |receiver, arguments|
  print arguments.first.ruby_value
  arguments[0] || Constants["nil"] # We always want to return objects from our runtime
end
Constants["Object"].def :call do |receiver, arguments|
  receiver
end
Constants["Number"].def :+ do|receiver,arguments|
  result = receiver.ruby_value + arguments.first.ruby_value
  Constants["Number"].new_with_value(result)
end
Constants["Number"].def :- do|receiver,arguments|
  result = receiver.ruby_value - arguments.first.ruby_value
  Constants["Number"].new_with_value(result)
end
Constants["Number"].def :< do|receiver,arguments|
  result = receiver.ruby_value < arguments.first.ruby_value
  Constants["Number"].new_with_value(result)
end
Constants["Number"].def :> do|receiver,arguments|
  result = receiver.ruby_value > arguments.first.ruby_value
  Constants["Number"].new_with_value(result)
end
Constants["Number"].def :<= do|receiver,arguments|
  result = receiver.ruby_value <= arguments.first.ruby_value
  Constants["Number"].new_with_value(result)
end
Constants["Number"].def :>= do|receiver,arguments|
  result = receiver.ruby_value >= arguments.first.ruby_value
  Constants["Number"].new_with_value(result)
end
Constants["Number"].def :* do|receiver,arguments|
  result = receiver.ruby_value * arguments.first.ruby_value
  Constants["Number"].new_with_value(result)
end
Constants["Number"].def :/ do|receiver,arguments|
  result = receiver.ruby_value / arguments.first.ruby_value
  Constants["Number"].new_with_value(result)
end

def define_is(type)
  Constants[type].def :is do|receiver, arguments|
    result = receiver.ruby_value == arguments.first.ruby_value
    if result
      Constants["true"]
    else
      Constants["false"]
    end
  end
end

def define_isnt(type)
  Constants[type].def :isnt do|receiver, arguments|
    result = receiver.ruby_value != arguments.first.ruby_value
    if result
      Constants["true"]
    else
      Constants["false"]
    end
  end
end

def define_and(type)
  Constants[type].def :and do|receiver, arguments|
    result = receiver.ruby_value && arguments.first.ruby_value
    if result
      Constants["true"]
    else
      Constants["false"]
    end
  end
end

def define_or(type)
  Constants[type].def :or do|receiver, arguments|
    result = receiver.ruby_value || arguments.first.ruby_value
    if result
      Constants["true"]
    else
      Constants["false"]
    end
  end
end
#["Number", "String", "FalseClass", "TrueClass", "Class", "NilClass"].each do |k, _|
#  define_is(k)
#  define_isnt(k)
#  define_and(k)
#  define_or(k)
#  Constants[k].def :not do|receiver, arguments|
#    if !receiver.ruby_value
#      Constants["true"]
#    else
#      Constants["false"]
#    end
#  end
#end
k = "Object"
define_is(k)
define_isnt(k)
define_and(k)
define_or(k)
Constants[k].def :not do|receiver, arguments|
  if !receiver.ruby_value
    Constants["true"]
  else
    Constants["false"]
  end
end



Constants["Array"].def :get do |receiver, arguments|
  (receiver.ruby_value[arguments[0].ruby_value-1]) || Constants["nil"]
end
Constants["Array"].def :set do |receiver, arguments|
  receiver.ruby_value[arguments[0].ruby_value-1] = arguments[1] || Constants["nil"]
end
Constants["Array"].def :length do |receiver, arguments|
  Constants["Number"].new_with_value(receiver.ruby_value.count) || Constants["nil"]
end
Constants["String"].def :set do |receiver, arguments|
  raise "Attempt to set on immutable string object!"
end
