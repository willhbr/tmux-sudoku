sud = File.read 'sudoku'

res = ''
sud.lines.each_with_index do |row, y|
  row.split('').each_with_index do |num, x|
    if num != "\n"
      res += "set -s @x#{x + 1}y#{y + 1} '#{num}'\n"
    end
  end
end

File.write 'sudoku-data.conf', res
