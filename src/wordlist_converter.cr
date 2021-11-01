require "levenshtein"

class WordlistConverter
  property words, next_words

  def initialize(filename)
    @words = [] of String
    @next_words = {} of String => Array(String)

    File.open(filename, "r").each_line do |line|
      next if line.includes?("'")

      word = line.downcase

      words.push(word)
      next_words[word] = [] of String
      # break if words.size > 200 # DEBUG
    end

    puts "read #{words.size} words"

    populate_next_words
  end

  private def populate_next_words
    channel = Channel(Nil).new

    num_threads = 6
    slice_size = (words.size / num_threads).ceil.to_i # ceil returns a Float because Int has a lower max

    num_threads.times do |i|
      spawn do
        slice_offset = slice_size * i
        populate_next_words_range(slice_offset, slice_offset + slice_size)
        channel.send(nil)
      end
    end

    num_threads.times { channel.receive }
  end

  private def populate_next_words_range(range_start, range_end)
    range_end = Math.min(range_end, words.size - 1)
    (range_start..range_end).each do |i|
      puts "#{i}: #{words[i]}" # for monitoring output
      next_words_for_word = (0..words.size - 1)
        .map { |ii| [words[ii], Levenshtein.distance(words[i], words[ii])] }
        .map { |pair| pair[0] if pair[1] == 1 }
        .compact
        .map(&.to_s)

      next_words[words[i]] = next_words_for_word
    end
  end
end
