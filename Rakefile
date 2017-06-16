require 'json'
require 'fileutils'

# To run via Docker:
#
#   docker run -it --rm -v "$(pwd)":/src ruby bash -c "cd /src && bundle install && rake"

# Unicode Regexp is derived from https://github.com/mathiasbynens/emoji-regex
UNICODE_REGEXP = /\u{1F469}(?:\u200D(?:(?:\u{1F469}\u200D)?\u{1F467}|(?:\u{1F469}\u200D)?\u{1F466})|[\u{1F3FB}-\u{1F3FF}])|\u{1F469}\u200D(?:\u{1F469}\u200D)?\u{1F466}\u200D\u{1F466}|\u{1F469}\u200D(?:\u{1F469}\u200D)?\u{1F467}\u200D(?:[\u{1F466}\u{1F467}])|\u{1F3F3}\uFE0F\u200D\u{1F308}|(?:[\u{1F3C3}\u{1F3C4}\u{1F3CA}\u{1F46E}\u{1F471}\u{1F473}\u{1F477}\u{1F481}\u{1F482}\u{1F486}\u{1F487}\u{1F645}-\u{1F647}\u{1F64B}\u{1F64D}\u{1F64E}\u{1F6A3}\u{1F6B4}-\u{1F6B6}\u{1F926}\u{1F937}-\u{1F939}\u{1F93D}\u{1F93E}\u{1F9D6}-\u{1F9DD}])(?:[\u{1F3FB}-\u{1F3FF}])\u200D[\u2640\u2642]\uFE0F|\u{1F469}(?:[\u{1F3FB}-\u{1F3FF}])\u200D(?:[\u{1F33E}\u{1F373}\u{1F393}\u{1F3A4}\u{1F3A8}\u{1F3EB}\u{1F3ED}\u{1F4BB}\u{1F4BC}\u{1F527}\u{1F52C}\u{1F680}\u{1F692}])|(?:[\u{1F3C3}\u{1F3C4}\u{1F3CA}\u{1F46E}\u{1F46F}\u{1F471}\u{1F473}\u{1F477}\u{1F481}\u{1F482}\u{1F486}\u{1F487}\u{1F645}-\u{1F647}\u{1F64B}\u{1F64D}\u{1F64E}\u{1F6A3}\u{1F6B4}-\u{1F6B6}\u{1F926}\u{1F937}-\u{1F939}\u{1F93C}-\u{1F93E}\u{1F9D6}-\u{1F9DF}])\u200D[\u2640\u2642]\uFE0F|\u{1F1FD}\u{1F1F0}|\u{1F1F6}\u{1F1E6}|\u{1F1F4}\u{1F1F2}|\u{1F1E9}(?:[\u{1F1EA}\u{1F1EC}\u{1F1EF}\u{1F1F0}\u{1F1F2}\u{1F1F4}\u{1F1FF}])|\u{1F1F7}(?:[\u{1F1EA}\u{1F1F4}\u{1F1F8}\u{1F1FA}\u{1F1FC}])|\u{1F1E8}(?:[\u{1F1E6}\u{1F1E8}\u{1F1E9}\u{1F1EB}-\u{1F1EE}\u{1F1F0}-\u{1F1F5}\u{1F1F7}\u{1F1FA}-\u{1F1FF}])|(?:[\u26F9\u{1F3CB}\u{1F3CC}\u{1F575}])(?:\uFE0F\u200D[\u2640\u2642]|(?:[\u{1F3FB}-\u{1F3FF}])\u200D[\u2640\u2642])\uFE0F|(?:\u{1F441}\uFE0F\u200D\u{1F5E8}|\u{1F469}(?:[\u{1F3FB}-\u{1F3FF}])\u200D[\u2695\u2696\u2708]|\u{1F469}\u200D[\u2695\u2696\u2708]|\u{1F468}(?:(?:[\u{1F3FB}-\u{1F3FF}])\u200D[\u2695\u2696\u2708]|\u200D[\u2695\u2696\u2708]))\uFE0F|\u{1F1F2}(?:[\u{1F1E6}\u{1F1E8}-\u{1F1ED}\u{1F1F0}-\u{1F1FF}])|\u{1F469}\u200D(?:[\u{1F33E}\u{1F373}\u{1F393}\u{1F3A4}\u{1F3A8}\u{1F3EB}\u{1F3ED}\u{1F4BB}\u{1F4BC}\u{1F527}\u{1F52C}\u{1F680}\u{1F692}]|\u2764\uFE0F\u200D(?:\u{1F48B}\u200D(?:[\u{1F468}\u{1F469}])|[\u{1F468}\u{1F469}]))|\u{1F1F1}(?:[\u{1F1E6}-\u{1F1E8}\u{1F1EE}\u{1F1F0}\u{1F1F7}-\u{1F1FB}\u{1F1FE}])|\u{1F1EF}(?:[\u{1F1EA}\u{1F1F2}\u{1F1F4}\u{1F1F5}])|\u{1F1ED}(?:[\u{1F1F0}\u{1F1F2}\u{1F1F3}\u{1F1F7}\u{1F1F9}\u{1F1FA}])|\u{1F1EB}(?:[\u{1F1EE}-\u{1F1F0}\u{1F1F2}\u{1F1F4}\u{1F1F7}])|[#\*0-9]\uFE0F\u20E3|\u{1F1E7}(?:[\u{1F1E6}\u{1F1E7}\u{1F1E9}-\u{1F1EF}\u{1F1F1}-\u{1F1F4}\u{1F1F6}-\u{1F1F9}\u{1F1FB}\u{1F1FC}\u{1F1FE}\u{1F1FF}])|\u{1F1E6}(?:[\u{1F1E8}-\u{1F1EC}\u{1F1EE}\u{1F1F1}\u{1F1F2}\u{1F1F4}\u{1F1F6}-\u{1F1FA}\u{1F1FC}\u{1F1FD}\u{1F1FF}])|\u{1F1FF}(?:[\u{1F1E6}\u{1F1F2}\u{1F1FC}])|\u{1F1F5}(?:[\u{1F1E6}\u{1F1EA}-\u{1F1ED}\u{1F1F0}-\u{1F1F3}\u{1F1F7}-\u{1F1F9}\u{1F1FC}\u{1F1FE}])|\u{1F1FB}(?:[\u{1F1E6}\u{1F1E8}\u{1F1EA}\u{1F1EC}\u{1F1EE}\u{1F1F3}\u{1F1FA}])|\u{1F1F3}(?:[\u{1F1E6}\u{1F1E8}\u{1F1EA}-\u{1F1EC}\u{1F1EE}\u{1F1F1}\u{1F1F4}\u{1F1F5}\u{1F1F7}\u{1F1FA}\u{1F1FF}])|\u{1F3F4}\u{E0067}\u{E0062}(?:\u{E0077}\u{E006C}\u{E0073}|\u{E0073}\u{E0063}\u{E0074}|\u{E0065}\u{E006E}\u{E0067})\u{E007F}|\u{1F468}(?:\u200D(?:\u2764\uFE0F\u200D(?:\u{1F48B}\u200D)?\u{1F468}|(?:(?:[\u{1F468}\u{1F469}])\u200D)?\u{1F466}\u200D\u{1F466}|(?:(?:[\u{1F468}\u{1F469}])\u200D)?\u{1F467}\u200D(?:[\u{1F466}\u{1F467}])|[\u{1F33E}\u{1F373}\u{1F393}\u{1F3A4}\u{1F3A8}\u{1F3EB}\u{1F3ED}\u{1F4BB}\u{1F4BC}\u{1F527}\u{1F52C}\u{1F680}\u{1F692}])|(?:[\u{1F3FB}-\u{1F3FF}])\u200D(?:[\u{1F33E}\u{1F373}\u{1F393}\u{1F3A4}\u{1F3A8}\u{1F3EB}\u{1F3ED}\u{1F4BB}\u{1F4BC}\u{1F527}\u{1F52C}\u{1F680}\u{1F692}]))|\u{1F1F8}(?:[\u{1F1E6}-\u{1F1EA}\u{1F1EC}-\u{1F1F4}\u{1F1F7}-\u{1F1F9}\u{1F1FB}\u{1F1FD}-\u{1F1FF}])|\u{1F1F0}(?:[\u{1F1EA}\u{1F1EC}-\u{1F1EE}\u{1F1F2}\u{1F1F3}\u{1F1F5}\u{1F1F7}\u{1F1FC}\u{1F1FE}\u{1F1FF}])|\u{1F1FE}(?:[\u{1F1EA}\u{1F1F9}])|\u{1F1EE}(?:[\u{1F1E8}-\u{1F1EA}\u{1F1F1}-\u{1F1F4}\u{1F1F6}-\u{1F1F9}])|\u{1F1F9}(?:[\u{1F1E6}\u{1F1E8}\u{1F1E9}\u{1F1EB}-\u{1F1ED}\u{1F1EF}-\u{1F1F4}\u{1F1F7}\u{1F1F9}\u{1F1FB}\u{1F1FC}\u{1F1FF}])|\u{1F1EC}(?:[\u{1F1E6}\u{1F1E7}\u{1F1E9}-\u{1F1EE}\u{1F1F1}-\u{1F1F3}\u{1F1F5}-\u{1F1FA}\u{1F1FC}\u{1F1FE}])|\u{1F1FA}(?:[\u{1F1E6}\u{1F1EC}\u{1F1F2}\u{1F1F3}\u{1F1F8}\u{1F1FE}\u{1F1FF}])|\u{1F1EA}(?:[\u{1F1E6}\u{1F1E8}\u{1F1EA}\u{1F1EC}\u{1F1ED}\u{1F1F7}-\u{1F1FA}])|\u{1F1FC}(?:[\u{1F1EB}\u{1F1F8}])|(?:[\u26F9\u{1F3CB}\u{1F3CC}\u{1F575}])(?:[\u{1F3FB}-\u{1F3FF}])|(?:[\u{1F3C3}\u{1F3C4}\u{1F3CA}\u{1F46E}\u{1F471}\u{1F473}\u{1F477}\u{1F481}\u{1F482}\u{1F486}\u{1F487}\u{1F645}-\u{1F647}\u{1F64B}\u{1F64D}\u{1F64E}\u{1F6A3}\u{1F6B4}-\u{1F6B6}\u{1F926}\u{1F937}-\u{1F939}\u{1F93D}\u{1F93E}\u{1F9D6}-\u{1F9DD}])(?:[\u{1F3FB}-\u{1F3FF}])|(?:[\u261D\u270A-\u270D\u{1F385}\u{1F3C2}\u{1F3C7}\u{1F442}\u{1F443}\u{1F446}-\u{1F450}\u{1F466}\u{1F467}\u{1F470}\u{1F472}\u{1F474}-\u{1F476}\u{1F478}\u{1F47C}\u{1F483}\u{1F485}\u{1F4AA}\u{1F574}\u{1F57A}\u{1F590}\u{1F595}\u{1F596}\u{1F64C}\u{1F64F}\u{1F6C0}\u{1F6CC}\u{1F918}-\u{1F91C}\u{1F91E}\u{1F91F}\u{1F930}-\u{1F936}\u{1F9D1}-\u{1F9D5}])(?:[\u{1F3FB}-\u{1F3FF}])|\u{1F468}(?:\u200D(?:(?:(?:[\u{1F468}\u{1F469}])\u200D)?\u{1F467}|(?:(?:[\u{1F468}\u{1F469}])\u200D)?\u{1F466})|[\u{1F3FB}-\u{1F3FF}])|[\u261D\u26F9\u270A-\u270D\u{1F385}\u{1F3C2}-\u{1F3C4}\u{1F3C7}\u{1F3CA}-\u{1F3CC}\u{1F442}\u{1F443}\u{1F446}-\u{1F450}\u{1F466}-\u{1F469}\u{1F46E}\u{1F470}-\u{1F478}\u{1F47C}\u{1F481}-\u{1F483}\u{1F485}-\u{1F487}\u{1F4AA}\u{1F574}\u{1F575}\u{1F57A}\u{1F590}\u{1F595}\u{1F596}\u{1F645}-\u{1F647}\u{1F64B}-\u{1F64F}\u{1F6A3}\u{1F6B4}-\u{1F6B6}\u{1F6C0}\u{1F6CC}\u{1F918}-\u{1F91C}\u{1F91E}\u{1F91F}\u{1F926}\u{1F930}-\u{1F939}\u{1F93D}\u{1F93E}\u{1F9D1}-\u{1F9DD}][\u{1F3FB}-\u{1F3FF}]?|[\u231A\u231B\u23E9-\u23EC\u23F0\u23F3\u25FD\u25FE\u2614\u2615\u2648-\u2653\u267F\u2693\u26A1\u26AA\u26AB\u26BD\u26BE\u26C4\u26C5\u26CE\u26D4\u26EA\u26F2\u26F3\u26F5\u26FA\u26FD\u2705\u270A\u270B\u2728\u274C\u274E\u2753-\u2755\u2757\u2795-\u2797\u27B0\u27BF\u2B1B\u2B1C\u2B50\u2B55\u{1F004}\u{1F0CF}\u{1F18E}\u{1F191}-\u{1F19A}\u{1F1E6}-\u{1F1FF}\u{1F201}\u{1F21A}\u{1F22F}\u{1F232}-\u{1F236}\u{1F238}-\u{1F23A}\u{1F250}\u{1F251}\u{1F300}-\u{1F320}\u{1F32D}-\u{1F335}\u{1F337}-\u{1F37C}\u{1F37E}-\u{1F393}\u{1F3A0}-\u{1F3CA}\u{1F3CF}-\u{1F3D3}\u{1F3E0}-\u{1F3F0}\u{1F3F4}\u{1F3F8}-\u{1F43E}\u{1F440}\u{1F442}-\u{1F4FC}\u{1F4FF}-\u{1F53D}\u{1F54B}-\u{1F54E}\u{1F550}-\u{1F567}\u{1F57A}\u{1F595}\u{1F596}\u{1F5A4}\u{1F5FB}-\u{1F64F}\u{1F680}-\u{1F6C5}\u{1F6CC}\u{1F6D0}-\u{1F6D2}\u{1F6EB}\u{1F6EC}\u{1F6F4}-\u{1F6F8}\u{1F910}-\u{1F93A}\u{1F93C}-\u{1F93E}\u{1F940}-\u{1F945}\u{1F947}-\u{1F94C}\u{1F950}-\u{1F96B}\u{1F980}-\u{1F997}\u{1F9C0}\u{1F9D0}-\u{1F9E6}]|[#\*0-9\u00A9\u00AE\u203C\u2049\u2122\u2139\u2194-\u2199\u21A9\u21AA\u231A\u231B\u2328\u23CF\u23E9-\u23F3\u23F8-\u23FA\u24C2\u25AA\u25AB\u25B6\u25C0\u25FB-\u25FE\u2600-\u2604\u260E\u2611\u2614\u2615\u2618\u261D\u2620\u2622\u2623\u2626\u262A\u262E\u262F\u2638-\u263A\u2640\u2642\u2648-\u2653\u2660\u2663\u2665\u2666\u2668\u267B\u267F\u2692-\u2697\u2699\u269B\u269C\u26A0\u26A1\u26AA\u26AB\u26B0\u26B1\u26BD\u26BE\u26C4\u26C5\u26C8\u26CE\u26CF\u26D1\u26D3\u26D4\u26E9\u26EA\u26F0-\u26F5\u26F7-\u26FA\u26FD\u2702\u2705\u2708-\u270D\u270F\u2712\u2714\u2716\u271D\u2721\u2728\u2733\u2734\u2744\u2747\u274C\u274E\u2753-\u2755\u2757\u2763\u2764\u2795-\u2797\u27A1\u27B0\u27BF\u2934\u2935\u2B05-\u2B07\u2B1B\u2B1C\u2B50\u2B55\u3030\u303D\u3297\u3299\u{1F004}\u{1F0CF}\u{1F170}\u{1F171}\u{1F17E}\u{1F17F}\u{1F18E}\u{1F191}-\u{1F19A}\u{1F1E6}-\u{1F1FF}\u{1F201}\u{1F202}\u{1F21A}\u{1F22F}\u{1F232}-\u{1F23A}\u{1F250}\u{1F251}\u{1F300}-\u{1F321}\u{1F324}-\u{1F393}\u{1F396}\u{1F397}\u{1F399}-\u{1F39B}\u{1F39E}-\u{1F3F0}\u{1F3F3}-\u{1F3F5}\u{1F3F7}-\u{1F4FD}\u{1F4FF}-\u{1F53D}\u{1F549}-\u{1F54E}\u{1F550}-\u{1F567}\u{1F56F}\u{1F570}\u{1F573}-\u{1F57A}\u{1F587}\u{1F58A}-\u{1F58D}\u{1F590}\u{1F595}\u{1F596}\u{1F5A4}\u{1F5A5}\u{1F5A8}\u{1F5B1}\u{1F5B2}\u{1F5BC}\u{1F5C2}-\u{1F5C4}\u{1F5D1}-\u{1F5D3}\u{1F5DC}-\u{1F5DE}\u{1F5E1}\u{1F5E3}\u{1F5E8}\u{1F5EF}\u{1F5F3}\u{1F5FA}-\u{1F64F}\u{1F680}-\u{1F6C5}\u{1F6CB}-\u{1F6D2}\u{1F6E0}-\u{1F6E5}\u{1F6E9}\u{1F6EB}\u{1F6EC}\u{1F6F0}\u{1F6F3}-\u{1F6F8}\u{1F910}-\u{1F93A}\u{1F93C}-\u{1F93E}\u{1F940}-\u{1F945}\u{1F947}-\u{1F94C}\u{1F950}-\u{1F96B}\u{1F980}-\u{1F997}\u{1F9C0}\u{1F9D0}-\u{1F9E6}]\uFE0F/u

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

def preprocess_emoji_json(parsed)
  new = []

  parsed.each do |emoji|
    next unless emoji["has_img_apple"]

    aliases = emoji["short_names"].dup
    aliases.delete(emoji["short_name"])

    short_name = emoji["short_name"]
    unicode_points = emoji["unified"]
    category = emoji["category"]

    category = "Flags" if short_name =~ /flag-/ && category.nil?

    unicode = unicode_points.split('-').map(&:hex).pack('U*')

    # Append VS16 to code points which require it for display
    if !UNICODE_REGEXP.match?(unicode) && UNICODE_REGEXP.match?("#{unicode}\uFE0F")
      unicode_points = "#{unicode_points}-FE0F"
    end

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
