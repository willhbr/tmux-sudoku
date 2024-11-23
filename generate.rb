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
  [0, 1, 2].each do |ax|
    [0, 1, 2].each do |ay|
      xy x + ax, y + ay
    end
  end.flatten
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

compiled = ERB.new(File.read(ARGV[0])).result(binding)
File.write(ARGV[1], compiled)
