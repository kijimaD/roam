require 'open3'

rows = Open3.capture2('git ls-files *.org | xargs wc -c | sort -n').first.split("\n")
sum = rows.last.split(' ').first.to_f

puts '* File ranking'
puts '| Character | Title | Percent |'

rows.each do |row|
  count, title = row.strip.split(' ')
  percent = ((count.to_i / sum).round(4) * 100).round(2)
  title = title.gsub(/[0-9]{14}-/, '')

  puts "| #{count} | #{title} | #{percent} |"
end
