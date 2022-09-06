require 'json'
require 'fileutils'

# To run via Docker:
#
#   docker run -it --rm -v "$(pwd)":/src ruby bash -c "cd /src && bundle install && rake"

desc "Pick a random emoji"
task :random do
  emojis = []

  emojis_dir = __dir__
  Dir.glob("#{emojis_dir}/img-*.json").each do |catalogue|
    emojis.concat JSON.parse(File.read(catalogue)).reverse
  end

  emoj = emojis[Random.rand(emojis.count)]

  puts ":#{emoj['name']}:"
end

desc "Generate a table to be copy and pasted into the readme when emojis are updated"
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
      %{<img src="#{emoji['image']}" width="20" height="20" alt="#{emoji['name']}"/>},
      [ emoji['name'], emoji['aliases'] ].flatten.compact.uniq.map{|s| "`:#{s}:`" }.join(", ")
    ]

    if emoji['modifiers'] && emoji['modifiers'].length > 0
      emoji['modifiers'].each do |modifier|
        groups[category] << [
          %{<img src="#{modifier['image']}" width="20" height="20" alt="#{emoji['name']}"/>},
          "`:#{emoji['name']}::#{modifier['name']}:`"
        ]
      end
    end
  end

  order = ["Buildkite",
           "Smileys & Emotion",
           "People & Body",
           "Animals & Nature",
           "Food & Drink",
           "Activities",
           "Travel & Places",
           "Objects",
           "Symbols",
           "Flags"]

  order.each do |name|
    rows = groups.delete(name)

    # Reverse the order of the BK group so the latest emojis get added to the top
    rows = rows.reverse if name == "Buildkite"

    puts "### #{name}\n\n"
    puts "Emoji | Aliases"
    puts "----- | -------"
    rows.each do |cols|
      puts cols.join(" | ")
    end
    puts "\n"
  end

  if groups.keys.length > 0
    raise "Not all groups were shown: `#{groups.keys.inspect}`"
  end
end

desc "Check there are no duplicate emoji names"
task :verify do
  # These duplicates existed prior to the addition of this check,
  # so just print them as a warning
  ignored_duplicates = [
    'beetle',
    'cucumber',
    'family',
    'llama',
    'man-woman-boy',
    'man_in_tuxedo',
    'yarn',
    'troll',
  ]

  emoji_names = []

  Dir.glob("img-*.json").each do |catalogue_file|
    catalogue_data = JSON.parse(File.read(catalogue_file))

    catalogue_data.each do |emoji|
      emoji_names.concat([ emoji['name'], emoji['aliases'] ].flatten.compact)
    end
  end

  emoji_names.sort!

  File.write(
    "#{__dir__}/all_emoji_names.txt",
    emoji_names.join("\n")
  )

  warning_emoji_names = []
  error_emoji_names = []

  emoji_names.group_by { |name| name }.select { |_, list| list.size > 1 }.map do |list|
    name = list.first

    if ignored_duplicates.include?(name)
      warning_emoji_names << ":#{name}: (#{name}) refers to #{list.length} emoji"
    else
      error_emoji_names << ":#{name}: (#{name}) refers to #{list.length} emoji"
    end
  end

  if warning_emoji_names.any?
    puts "WARNING: Ignored duplicate emoji names:\n - #{warning_emoji_names.join("\n - ")}\n"
  end

  if error_emoji_names.any?
    puts "ERROR: Unexpected duplicate emoji names:\n - #{error_emoji_names.join("\n - ")}\n"
    exit 1
  end
end

def preprocess_emoji_json(parsed)
  new = []

  parsed.each do |emoji|
    next unless emoji["has_img_apple"]

    aliases = emoji["short_names"].dup
    aliases.delete(emoji["short_name"])

    short_name = emoji["short_name"]
    unicode_points = emoji["unified"]
    category = emoji["category"]

    modifiers = []

    if emoji["skin_variations"] && !emoji["skin_variations"].empty?
      emoji["skin_variations"].each_with_index do |(key, skin), i|
        modifiers << {
          name: "skin-tone-#{i + 2}",
          image: "img-apple-64/#{skin['image']}",
          unicode: skin["unified"]
        }
      end
    end

    new << {
      name: short_name,
      category: category,
      image: "img-apple-64/#{emoji['image']}",
      unicode: unicode_points,
      aliases: aliases,
      modifiers: modifiers
    }
  end

  JSON.pretty_generate(new)
end

desc "Generate and show processed emoji data file"
task :generate do
  parsed = JSON.parse(File.read(ENV.fetch("EMOJI_JSON")))
  puts preprocess_emoji_json(parsed)
end

desc "Synchronise emoji data and images"
task :sync do
  puts 'Synchronising Unicode emoji images...'
  FileUtils.cp(
    Dir["#{__dir__}/node_modules/emoji-datasource-apple/img/apple/64/*.png"],
    "#{__dir__}/img-apple-64"
  )

  puts 'Synchronising Unicode emoji metadata...'
  unicode_emoji_catalogue = JSON.parse(File.read("#{__dir__}/node_modules/emoji-datasource-apple/emoji.json"))
  File.write(
    "#{__dir__}/img-apple-64.json",
    preprocess_emoji_json(unicode_emoji_catalogue)
  )

  puts 'Done!'
end
