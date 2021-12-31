require_relative 'db'
require_relative 'ls'

class Table
  def run
    results = Hash.new

    db = Db.new.run
    ls = Ls.new.run

    db.each do |k, v|
      next unless ls[k]

      results.store(k, v.merge(ls[k]))
    end

    results = results.sort { |(k1, v1), (k2, v2)| v2[:rank] <=> v1[:rank] }
    print(results)
  end

  def print(results)
    puts '* Node Analysis'
    puts '| Page Rank | Title | Char Count | Volume | Last Changed |'

    results.each do |result|
      file = result[0]

      title = result[1][:title]
      rank = result[1][:rank]
      count = result[1][:count]
      percent = result[1][:percent]
      last_changed = result[1][:last_changed]
        text = <<~TEXT
                | #{rank} \
                | [[file:#{file}][#{title}]] \
                | #{count} \
                | #{percent} \
                | #{last_changed} \
                |
              TEXT
        puts text.gsub(/(\n)/,'')
    end
  end
end

Table.new.run
