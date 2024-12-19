#!/usr/bin/ruby
require 'erb'

def every_xy
  (1..9).map do |y|
    (1..9).map do |x|
      yield xy_unformatted(x ,y)
    end
  end.flatten
end

def xy_unformatted(x, y)
  "@x#{x}y#{y}"
end

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
  "\#{?\#{m:*0*,#{buff.join}},0,1}"
end

def is_ok(exprs)
  all_exprs = exprs.join
  (1..9).map do |i|
    "\#{m:*#{i}*,#{all_exprs}}"
  end.join
end

def show_state
  (1..9).map do |y|
    line = (1..9).map do |x|
      if '36'.include? x.to_s
        a = xy x, y
        a + '│'
      else
        xy x, y
      end
    end.join
    if '36'.include? y.to_s
      line + '\n───┼───┼───'
    else
      line
    end
  end.join('\n')
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

def copy_options(new_session)
  every_xy do |cell|
    "tmux set -t #{new_session} #{cell} \"\#{#{cell}}\""
  end.join(';')
end

def subs(var, idx)
  var_len = "\#{n:#{var}}"
  start_idx = "\#{e|*:2,#{idx}}"
  end_idx = "\#{e|-:#{var_len},#{start_idx}}"
  front_truncated = "\#{=-#{end_idx}:@blanks}"
  "\#{=2:#{front_truncated}}"
end

def x_sub(var, idx)
  var_len = "\#{n:#{var}}"
  start_idx = "\#{e|*:2,#{idx}}"
  end_idx = "\#{e|-:#{var_len},#{start_idx}}"
  front_truncated = "\#{=-#{end_idx}:@blanks}"
  "\#{=1:#{front_truncated}}"
end

def y_sub(var, idx)
  var_len = "\#{n:#{var}}"
  start_idx = "\#{e|*:2,#{idx}}"
  end_idx = "\#{e|-:\#{e|-:#{var_len},#{start_idx}},1}"
  front_truncated = "\#{=-#{end_idx}:@blanks}"
  "\#{=1:#{front_truncated}}"
end

sud = File.read ARGV[0]

res = ''
blanks = []
sud.lines.each_with_index do |row, y|
  row.split('').each_with_index do |num, x|
    if num != "\n" && num != '|'
      if num == ' '
        num = '0'
        blanks << "#{x + 1}#{y + 1}"
      end
      res += "set @x#{x + 1}y#{y + 1} '#{num}'\n"
    end
  end
end

res += "set @blanks '#{blanks.join}'\n"

File.write 'sudoku-data.conf', res

output = 'sudoku-compiled.conf'
compiled = ERB.new(File.read('sudoku.conf')).result(binding)
File.write(output, compiled)

exec *(%w(tmux -L test-sock -f) + [output] + %w(attach))
