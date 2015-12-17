# Generates a table to be copy and pasted into the readme when emojis are updated
#
# To run via Docker:
# 
#   docker run -it --rm -v "$(pwd)":/src ruby bash -c "cd /src && bundle install && rake"

require 'bundler/setup'
require 'json'
require 'gemoji'

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
      %{<img src="https://raw.githubusercontent.com/buildkite/emojis/master/images/#{emoji.image_filename}" width="20" height="20" alt="#{emoji.name}"/>},
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
