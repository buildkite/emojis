# Generates a table to be copy and pasted into the readme when emojis are updated
#
# To run via Docker:
#
#   docker run -it --rm -v "$(pwd)":/src ruby bash -c "cd /src && bundle install && rake"

require 'json'

task :default do
  emojis = []

  Dir.glob("img-*.json").each do |catalogue|
    emojis.concat JSON.parse(File.read(catalogue)).reverse
  end

  rows = []
  emojis.each do |emoji|
    rows << [
      %{<img src="https://raw.githubusercontent.com/buildkite/emojis/master/#{emoji['image']}" width="20" height="20" alt="#{emoji['name']}"/>},
      [ emoji['name'], emoji['aliases'] ].flatten.compact.uniq.join(", ")
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

task :generate do
  parsed = JSON.parse(File.read(ENV.fetch("EMOJI_JSON")))
  new = []

  parsed.each do |e|
    next if not e["has_img_apple"]

    aliases = e["short_names"].dup
    aliases.delete(e["short_name"])

    name = e["short_name"]
    category = e["category"]

    category = "Flags" if name =~ /flag-/ && category.nil?

    modifiers = []

    if e["skin_variations"] && e["skin_variations"].length > 0
      e["skin_variations"].each_with_index do |(key, skin), i|
        modifiers << {
          name: "skin-tone-#{i + 2}",
          image: "img-apple-64/#{skin["image"]}",
          unicode: skin["unified"]
        }
      end
    end

    new << {
      name: name,
      category: category,
      image: "img-apple-64/#{e["image"]}",
      unicode: e["unified"],
      aliases: aliases,
      modifiers: modifiers
    }
  end

  puts JSON.pretty_generate(new)
end

task :deploy do
  puts "I will deploy!"
end
