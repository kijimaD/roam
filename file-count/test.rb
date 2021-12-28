require "sqlite3"

# ["files"]
# ["nodes"]
# ["aliases"]
# ["citations"]
# ["refs"]
# ["tags"]
# ["links"]

# Open a database

db = SQLite3::Database.new "#{Dir.home}/.emacs.d/org-roam.db"

# db.execute( "select * from sqlite_master" ) do |master|
#   pp master
# end

# n1.id: from, n2.id: to
query = <<-SQL
    SELECT count(n2.id), n2.title, n2.file
    FROM nodes AS n1
    INNER JOIN links ON n1.id = links.source
    INNER JOIN nodes n2 ON links.dest = n2.id
    WHERE links.type = '\"id\"'
    GROUP BY(n2.id)
    ORDER BY(count(n2.id)) DESC
SQL

db.execute(query) do |arr|
  rank = arr[0]
  title = arr[1].gsub(/\"/, '')
  file = arr[2].split('/').last.gsub(/\"/, '')

  puts "#{rank} #{title} #{file}"
end
