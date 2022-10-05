defmodule Trie.WordSearchResult do
  defstruct [
    :rest_word,
    :origin_word,
    :word_path,
    :result,
    :match_detail
  ]
end
