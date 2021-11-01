class NextWordFinder
  property next_words, history

  @next_words : Hash(String, Array(String))

  def initialize(filename, history = [] of String)
    @history = history
    @next_words = File.open(filename, "r") { |file| Hash(String, Array(String)).from_json(file) }
  end

  def next_words(word)
    next_words[word] - history
  end

  def terminal_next_words(word)
    next_words[word].select do |w2|
      (next_words[w2] - history).size == 0
    end
  end

  def most_connected_next_words(word)
    next_words[word].max_by do |w2|
      (next_words[w2] - history).size
    end
  end
end
