#!/usr/bin/ruby
require 'erb'

def xy(x, y)
  "\#{@x#{x}y#{y}}"
end

def all_x(y)
  (1..9).map do |x|
    xy x, y
  end
end

def sum(exprs)
  exprs.reduce { |acc, ex| "\#{e|+:#{acc},#{ex}}" }
end

def everything_ok
  buff = []
  (1..9).each do |i|
    buff << is_ok(all_x(i))
    buff << is_ok(all_y(i))
    buff << is_ok(cell(i))
  end
  buff.reduce { |acc, ex| "\#{&&:#{acc},#{ex}}" }
end

def is_ok(exprs)
  "\#{e|==:45,#{sum exprs}}"
end

def show(exprs)
  exprs.reduce { |acc, ex| "#{acc},#{ex}" }
end

def all_y(x)
  (1..9).map do |y|
    xy x, y
  end
end

def all_cell(x, y)
  [0, 1, 2].map do |ax|
    [0, 1, 2].map do |ay|
      xy x + ax, y + ay
    end
  end.flatten
end

def cell(i)
  all_cell ((i - 1) % 3) * 3 + 1, ((i - 1) / 3) * 3 + 1
end

sud = File.read 'sudoku'

res = ''
sud.lines.each_with_index do |row, y|
  row.split('').each_with_index do |num, x|
    if num != "\n" && num != '|'
      num = '0' if num == ' '
      res += "set -s @x#{x + 1}y#{y + 1} '#{num}'\n"
    end
  end
end

File.write 'sudoku-data.conf', res

output = 'sudoku-compiled.conf'
compiled = ERB.new(File.read('sudoku.conf')).result(binding)
File.write(output, compiled)

exec *(%w(tmux -L test-sock -f) + [output])
