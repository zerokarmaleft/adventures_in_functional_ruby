require 'java'
require 'jbundler'
require 'stunted'

%w{ PersistentArrayMap, PersistentHashMap, PersistentHashSet, PersistentList,
    PersistentQueue, PersistentStructMap, PersistentTreeMap, PersistentTreeSet,
    PersistentVector }.each do |data_structure|
  java_import "clojure.lang.#{ data_structure }"
end

%w{ Atom Agent Ref Var }.each do |primitive|
  java_import "clojure.lang.#{ primitive }"
end

sarah = PersistentHashMap.create(:name, "Sarah", :age, 25, :wears_glasses?, false)

# basic access
sarah.get(:age)
sarah[:age]

# sharing structure
becky = sarah.
  assoc(:name, "Becky").
  assoc(:age, 28)

# chaining value updates
sarah = sarah.
  assoc(:name, sarah[:name] + " Plain and Tall").
  assoc(:age, sarah[:age] + 1)

# functional value updates
module CoreBridge
  extend Stunted::Defn

  defn :update_in, -> m, k, f do
    m.assoc(k, f.call(m.get(k)))
  end
end
include CoreBridge

update_in.(sarah, :age, -> age { age.next })

java_import 'clojure.lang.Numbers'

module CoreBridge
  defn :inc, -> x { Numbers.inc(x) }
  defn :dec, -> x { Numbers.dec(x) }
end

update_in.(sarah, :age, inc)

# chaining functional value updates
class PersistentHashMap
  include Stunted::Chainable
end

sarah.
  assoc(:name, "Sarah Plain and Tall").
  pass_to(-> m { update_in.(m, :age, inc) })

# using functional value updates in a Atom
module CoreBridge
  defn :swap!, -> atom, f do
    atom.swap(f)
  end
end

x = Atom.new(0)
swap!.(x, inc)
swap!.(x, dec)
