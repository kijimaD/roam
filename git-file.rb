# https://tbpgr.hatenablog.com/entry/2016/10/13/221511
require 'open3'

BASE = './'.freeze
REGEXP = '*org'.freeze

Dir.chdir(BASE) do
  begin
    commits = Open3.capture2('git log --date=short --format="%H,%cd"').first
    ret = commits.each_line.to_a.reverse.each_with_object({}) do |line, memo|
      sha1_date = line.split(',')
      sha1 = sha1_date.first

      date = sha1_date.last.chomp.tr('-', '/')
      Open3.capture2("git checkout #{sha1}")
      file_count = Open3.capture2("git ls-files #{REGEXP} | wc -l").first.strip
      memo[date] = file_count
    end
    print ret.map{ |e| e.join(',') }.join("\n"), "\n"
  ensure
    system('git checkout main >& /dev/null')
  end
end

system('git checkout main >& /dev/null')
