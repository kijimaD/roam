require 'open3'

rows = Open3.capture2('git ls-files *.org | xargs wc -c | sort -nr').first.split("\n")
sum = rows.first.split(' ').first.to_f
rows.shift # remove sum

puts '* File ranking'
puts '| Char Count | Title | Percent |'

rows.each do |row|
  count, file = row.strip.split(' ')
  percent = ((count.to_i / sum).round(4) * 100).round(2)

  html = file.gsub(/\.org$/, "\.html")
  title = file.gsub(/[0-9]{14}-/, "").gsub(/\.org$/, "")

  puts "| #{count} | [[file:#{html}][#{title}]] | #{percent} |"
end
