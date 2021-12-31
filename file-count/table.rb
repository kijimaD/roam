require 'jekyll-timeago'
require_relative 'db'
require_relative 'ls'

class Table
  include Jekyll::Timeago

  def run
    results = Hash.new

    db = Db.new.run
    ls = Ls.new.run

    db.each do |k, v|
      next unless ls[k]

      results.store(k, v.merge(ls[k]))
    end

    results = results.sort { |(k1, v1), (k2, v2)| v2[:rank] <=> v1[:rank] }
    show(results)
  end

  def show(results)
    puts '* Node Analysis'
    puts '| Page Rank | Title | Char Count | Volume | Last Changed |'

    results.each do |result|
      file = result[0]

      title = result[1][:title]
      rank = result[1][:rank]
      count = result[1][:count]
      changed_count = result[1][:changed_count]
      percent = result[1][:percent]
      last_changed = timeago(result[1][:last_changed], depth: 1)
        text = <<~TEXT
                | #{rank} \
                | [[file:#{file}][#{title}]] \
                | #{count} \
                | #{changed_count} \
                | #{percent} \
                | #{last_changed} \
                |
              TEXT
        puts text.gsub(/(\n)/,'')
    end
  end
end

Table.new.run
