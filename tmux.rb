#!/usr/bin/ruby
require 'erb'

def xy(x, y)
  "\#{@x#{x}y#{y}}"
end

def all_x(y)
  (0...9).map do |x|
    xy x, y
  end
end

def grid_ok
  buff = []
  (0...9).each do |i|
    buff << is_ok(all_x(i))
    buff << is_ok(all_y(i))
    buff << is_ok(cell(i))
  end
  "\#{?\#{m:*0*,#{buff.join}},0,1}"
end

def is_ok(exprs)
  all_exprs = exprs.join
  (1..9).map do |i|
    "\#{m:*#{i}*,#{all_exprs}}"
  end.join
end

def show_state
  (0...9).map do |y|
    line = (0...9).map do |x|
      if '25'.include? x.to_s
        a = xy x, y
        a + '│'
      else
        xy x, y
      end
    end.join
    if '25'.include? y.to_s
      line + '\n───┼───┼───'
    else
      line
    end
  end.join('\n')
end

def all_y(x)
  (0...9).map do |y|
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
  all_cell (i % 3) * 3, (i / 3) * 3
end

def x_sub(var, idx)
  var_len = "\#{n:#{var}}"
  start_idx = "\#{e|*:2,#{idx}}"
  end_idx = "\#{e|-:#{var_len},#{start_idx}}"
  front_truncated = "\#{=-#{end_idx}:#{var}}"
  "\#{=1:#{front_truncated}}"
end

def y_sub(var, idx)
  var_len = "\#{n:#{var}}"
  start_idx = "\#{e|*:2,#{idx}}"
  end_idx = "\#{e|-:\#{e|-:#{var_len},#{start_idx}},1}"
  front_truncated = "\#{=-#{end_idx}:#{var}}"
  "\#{=1:#{front_truncated}}"
end

def more_array?(var, idx)
  var_len = "\#{n:#{var}}"
  i = "\#{e|*:2,#{idx}}"
  "\#{e|<:#{i},#{var_len}}"
end

sud = File.read ARGV[0]

res = ''
blanks = []
lines = sud.lines
(0...9).each do |y|
  row = lines[y].split('')
  (0...9).each do |x|
    num = row[x]
    if num.nil? || num == ' ' || num == "\n"
      blanks << "#{x}#{y}"
    else
      res += "set -g @x#{x}y#{y} '#{num}'\n"
    end
  end
end

res += "set -g @blanks '#{blanks.join}'\n"

File.write 'sudoku-data.conf', res

output = 'sudoku-compiled.conf'
automatic = false
socket = 'test-sock'
compiled = ERB.new(File.read('sudoku.conf')).result(binding)
File.write(output, compiled)

exec *(%w(tmux -L) + [socket, '-f'] + [output] + %w(attach))
