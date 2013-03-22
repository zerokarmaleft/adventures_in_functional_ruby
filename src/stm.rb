require 'java'
require 'jbundler'
require 'stunted'

java_import 'clojure.lang.LockingTransaction'
java_import 'clojure.lang.Ref'
java_import 'java.util.concurrent.Callable'
java_import 'java.util.concurrent.Executors'

module CoreBridge
  extend Stunted::Defn

  def sync(&block)
    LockingTransaction::run_in_transaction(-> { block.call })
  end
  defn :ref_set, -> ref, val { ref.set val }
  defn :alter, -> ref, f, *args { ref.alter f, args }
end

include CoreBridge

class Task
  include Callable

  def initialize(refs)
    @refs = refs
  end
  
  def call
    10000.times do
      @refs.each do |r|
        sync { ref_set.(r, r.deref.next) }
      end
    end
  end
end

puts "10,000 iterations of 10 threads incrementing each of 10 refs"
puts "Each ref should have a final result of 100,000"

refs    = (0...10).map { Ref.new(0) }
pool    = Executors::new_fixed_thread_pool 10
tasks   = (0...10).map { Task.new(refs) }
puts refs.map(&:deref).inspect

futures = pool.invoke_all(tasks)
futures.each { |f| f.get }
pool.shutdown

puts refs.map(&:deref).inspect
