require 'open3'

class Ls
  def run
    results = Hash.new

    wc.each do |k, v|
      results.store(k, v.merge(last_changed[k]))
    end

    results.each do |k, v|
      results.store(k, v.merge(changed_count[k]))
    end

    results
  end

  def wc
    results = Hash.new

    rows = Open3.capture2('git ls-files *.org | xargs wc -c | sort -nr').first.split("\n")
    sum = rows.first.split(' ').first.to_f
    rows.shift # remove sum

    # puts '* File ranking'
    # puts '| Char Count | Title | Percent |'

    rows.each do |row|
      count, file = row.strip.split(' ')
      percent = ((count.to_i / sum).round(4) * 100).round(2)

      results.store(file, { count: count, percent: percent})
      # puts "| #{count} | [[file:#{html}][#{title}]] | #{percent} |"
    end
    results
  end

  def last_changed
    @last_changed ||= last_changed_run
  end

  def last_changed_run
    results = Hash.new

    rows = Open3.capture2('git ls-files -z *.org | xargs -0 -n1 -I{} -- git log -1 --format="%ai {}" {}').first.split("\n")
    rows.each do |row|
      date = row.split(" ")[0]
      file = row.split(" ")[3]

      results.store(file, { last_changed: date })
    end
    results
  end

  def changed_count
    results = Hash.new

    rows = Open3.capture2('git log --name-only --oneline | grep -v " " | sort | uniq -c').first.split("\n")
    rows.each do |row|
      count = row.split(" ")[0]
      file = row.split(" ")[1]
      results.store(file, { changed_count: count })
    end
    results
  end
end

Ls.new.run
