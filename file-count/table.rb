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
  end
end

Table.new.run
