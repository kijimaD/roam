require "sqlite3"

DB_PATH = "org-roam.db".freeze

# tables
# ["files"]
# ["nodes"]
# ["aliases"]
# ["citations"]
# ["refs"]
# ["tags"]
# ["links"]

# specify
# db.execute( "select * from sqlite_master" ) do |master|
#   pp master
# end

# n1.id: from, n2.id: to

class Db
  def initialize
    @db = SQLite3::Database.new(DB_PATH)
    @results = Hash.new
  end

  def run
    results = file_list.merge(page_rank)
    # MEMO: 全く同じ構造でrankだけ違えて上書きするので、valueハッシュすべてで上書きで問題ない

    results
  end

  def file_list
    results = Hash.new
    query = <<-SQL
      SELECT f.title, f.file
      FROM files AS f
    SQL

    @db.execute(query) do |arr|
      title = arr[0].gsub(/\"/, '')
      file = arr[1].split('/').last.gsub(/\"/, '')

      results.store(file, { title: title, rank: 0 })
    end
    results
  end

  def page_rank
    results = Hash.new
    query = <<-SQL
      SELECT n2.title, n2.file, count(n2.id)
      FROM nodes AS n1
      INNER JOIN links ON n1.id = links.source
      INNER JOIN nodes n2 ON links.dest = n2.id
      WHERE links.type = '\"id\"'
      GROUP BY(n2.id)
      ORDER BY(count(n2.id)) DESC
    SQL

    @db.execute(query) do |arr|
      title = arr[0].gsub(/\"/, '')
      file = arr[1].split('/').last.gsub(/\"/, '')
      rank = arr[2]

      # puts "#{rank} #{title} #{file}"
      results.store(file, { title: title, rank: rank })
      # @results << { title: title, file: file, rank: rank }
    end
    results
  end
end

Db.new.run
