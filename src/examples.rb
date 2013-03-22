require 'java'
require 'jbundler'
require 'stunted'

java_import 'clojure.lang.Atom'
java_import 'clojure.lang.PersistentHashMap'

sarah = PersistentHashMap.create(:name, "Sarah", :age, 25, :wears_glasses?, false)

# basic access
puts "#{ sarah.get(:name) }'s age: #{ sarah.get(:age) }"
puts "#{ sarah[:name] }'s age: #{ sarah[:age] }"

# sharing structure
becky = sarah.
  assoc(:name, "Becky").
  assoc(:age, 28)
puts "Becky is created from Sarah, yet Sarah remains Sarah"
puts sarah.inspect
puts becky.inspect

# chaining value updates
sarah = sarah.
  assoc(:name, sarah[:name] + " Plain and Tall").
  assoc(:age, sarah[:age] + 1)
puts "The variable 'sarah' is rebound to a new Map with the modified keyvals"
puts sarah.inspect

# functional value updates
module CoreBridge
  extend Stunted::Defn

  defn :update_in, -> m, k, f do
    m.assoc(k, f.call(m.get(k)))
  end
end
include CoreBridge

puts "Updating a value with an anonymous lambda"
puts update_in.(sarah, :age, -> age { age.next }).inspect

java_import 'clojure.lang.Numbers'

module CoreBridge
  defn :inc, -> x { Numbers.java_send :inc, [Java::long], x }
  defn :dec, -> x { Numbers.java_send :dec, [Java::long], x }
end

puts "Updating a value with a named lambda"
puts update_in.(sarah, :age, inc).inspect

# chaining functional value updates
class PersistentHashMap
  include Stunted::Chainable
end

puts "Chaining functional value updates"
puts sarah.
  assoc(:name, "Sarah Plain and Tall").
  pass_to(-> m { update_in.(m, :age, inc) }).
  inspect

# using functional value updates in an Atom
module CoreBridge
  defn :swap!, -> atom, f do
    atom.swap(f)
  end
end

x = Atom.new(0)
puts "#{ x.inspect }: #{ x.deref }"
swap!.(x, inc)
puts "#{ x.inspect }: #{ x.deref }"
swap!.(x, dec)
puts "#{ x.inspect }: #{ x.deref }"
