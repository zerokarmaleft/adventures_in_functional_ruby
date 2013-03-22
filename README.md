adventures_in_functional_ruby
=============================

A combination of Brian Marick's
[Stunted](https://github.com/marick/stunted) library with
[Clojure](http://clojure.org)'s [persistent data
structures](http://clojure.org/data_structures) and [concurrency
primitives](http://clojure.org/concurrent_programming).

Running the examples
====================

First, run Bundler to fetch JBundler and Stunted:

```
        $ git clone https://github.com/zerokarmaleft/adventures_in_functional_ruby.git
        $ cd adventures_in_functional_ruby
        $ bundle install
```

Then, run JBundler to fetch the Clojure Jar:

```
        $ jbundle install
```

And finally, the examples:

```
        $ jruby src/examples.rb
        $ jruby src/stm.rb
```
