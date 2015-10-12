require 'bundler/setup'
require 'json'
require 'gemoji'
require 'terminal-table'

task :default do
  custom_emojis = JSON.parse(File.read("emojis.json"))
  custom_emojis.each do |name, aliases|
    Emoji.create(name) do |emoji|
      if aliases.kind_of?(Array)
        [aliases].flatten.each {|a| emoji.add_alias(a)}
      end
    end
  end

  rows = []
  Emoji.all.each do |emoji|
    rows << [
      "![#{emoji.name}](https://raw.githubusercontent.com/buildkite/emojis/master/images/#{emoji.image_filename})",
      [ emoji.name, emoji.aliases ].flatten.compact.uniq.join(", ")
    ]
  end

  # Reverse the rows so the latest emojis show up first
  rows = rows.reverse

  puts "Emoji | Aliases"
  puts "----- | -------"
  rows.each do |cols|
    puts cols.join(" | ")
  end
end
