require "sqlite3"

# ["files"]
# ["nodes"]
# ["aliases"]
# ["citations"]
# ["refs"]
# ["tags"]
# ["links"]

# Open a database
db = SQLite3::Database.new "/home/kijima/.emacs.d/org-roam.db"

db.execute( "select * from sqlite_master" ) do |master|
  pp master
end

db.execute( "select hash from files" ) do |file|
  # title = file[1].gsub(/\"/, '')
  # path = file[0].split('/').last.gsub(/\"/, '')
end

query = <<-SQL
    SELECT count(links.source), n1.id, nodes.id, n1.file, n1.title
    FROM nodes AS n1
    INNER JOIN links ON n1.id = links.source
    INNER JOIN (nodes AS n2) ON links.dest = nodes.id
    WHERE links.type = '\"id\"'
    GROUP BY(links.source)
    ORDER BY(count(links.source)) DESC
SQL

db.execute(query) do |file|
  p file
end
