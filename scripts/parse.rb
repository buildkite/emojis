require 'json'

parsed = JSON.parse(File.read("emoji_pretty.json"))
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
