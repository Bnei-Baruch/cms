#!/usr/bin/env ruby
require 'benchmark'



Benchmark.bm do|b|
  b.report("+= ") do
    a = 'aaaaaaaaaaaaa'
    r = 'sssssssssssss'
    c = 'eeeeeeeeeeeee'
    1_000_000.times { a+'s'+r+'r'+c}
  end

  b.report("<< ") do
    a = 'aaaaaaaaaaaaa'
    r = 'sssssssssssss'
    c = 'eeeeeeeeeeeee'
    1_000_000.times { "#{a}s#{r}r#{c}"}
  end
end
