require "json"
require "option_parser"

require "./next_word_finder"
require "./wordlist_converter"

module WordGameRuiner
  VERSION = "0.1.0"
end

mode = nil
next_mode = nil
wordlist_file = ""
output_file = ""
nextwords_file = ""
history = [] of String

OptionParser.parse do |parser|
  parser.banner = "Usage: word-game-ruiner [mode] [arguments]"
  parser.on("generate", "generate nextlist") do
    mode = :generate
    parser.on("-w VALUE", "--wordlist=VALUE", "list of valid words") { |value| wordlist_file = value }
    parser.on("-o VALUE", "--output=VALUE", "output file") { |value| output_file = value }
  end
  parser.on("next", "find next word") do
    mode = :next
    parser.on("-n VALUE", "--next-words=VALUE", "list of computed next words") { |value| nextwords_file = value }
    parser.on("-g VALUE", "--history=VALUE", "words played so far") { |value| history = value.split(",").map(&.strip) }
    parser.on("-t", "--terminate", "find word with no legal next words") { next_mode = :terminate }
    parser.on("-m", "--maximize", "find word with greatest number of legal next words") { next_mode = :maximize }
  end
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

if mode == :generate
  unless wordlist_file.size > 0
    STDERR.puts "wordlist is required (try /usr/share/dict/words)"
    exit 1
  end

  converter = WordlistConverter.new(wordlist_file)
  File.write(output_file, converter.to_json)
elsif mode == :next
  unless nextwords_file.size > 0
    STDERR.puts "nextwords list is required. Use generate mode first."
    exit 2
  end
  unless history.size > 0
    STDERR.puts "non-empty history is required"
    exit 3
  end

  finder = NextWordFinder.new(nextwords_file, history: history)
  case next_mode
  when :terminate
    puts finder.terminal_next_words(history.last)
  when :maximize
    puts finder.most_connected_next_words(history.last)
  else
    puts finder.next_words(history.last)
  end
else
  raise Exception.new("no mode specified")
end
