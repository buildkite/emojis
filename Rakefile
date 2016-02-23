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

  groups = {}

  emojis.each do |emoji|
    category = emoji['category']

    next if emoji['name'] =~ /skin-tone/
    raise "No category for emoji: #{emoji.inspect}" if category.nil?

    groups[category] ||= []
    groups[category] << [
      %{<img src="https://raw.githubusercontent.com/buildkite/emojis/master/#{emoji['image']}" width="20" height="20" alt="#{emoji['name']}"/>},
      [ emoji['name'], emoji['aliases'] ].flatten.compact.uniq.map{|s| "`:#{s}:`" }.join(", ")
    ]

    if emoji['modifiers'] && emoji['modifiers'].length > 0
      emoji['modifiers'].each do |modifier|
        groups[category] << [
          %{<img src="https://raw.githubusercontent.com/buildkite/emojis/master/#{modifier['image']}" width="20" height="20" alt="#{emoji['name']}"/>},
          "`:#{emoji['name']}::#{modifier['name']}:`"
        ]
      end
    end
  end

  order = ["Buildkite", "People", "Nature", "Foods", "Activity", "Places", "Objects", "Symbols", "Flags"]

  order.each do |name|
    rows = groups.delete(name)

    # Reverse the order of the BK group so the latest emojis get added to the top
    rows = rows.reverse if name == "Buildkite"

    puts "## #{name}\n\n"
    puts "Emoji | Aliases"
    puts "----- | -------"
    rows.each do |cols|
      puts cols.join(" | ")
    end
    puts "\n"
  end

  if groups.keys.length > 0
    raise "Now all groups were shown: `#{group.keys.inspect}`"
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
