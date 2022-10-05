# https://leetcode.com/problems/implement-trie-prefix-tree/
# https://leetcode.com/submissions/detail/815807382/

defmodule Trie do
  @spec init_() :: any
  def init_() do
    Trie.GenServerStore.start_link()
  end

  @spec insert(word :: String.t()) :: any
  def insert(word) do
    Trie.GenServerStore.handle_insert(word)
  end

  @spec search(word :: String.t()) :: boolean
  def search(word) do
    Trie.GenServerStore.handle_search(word)
  end

  @spec starts_with(prefix :: String.t()) :: boolean
  def starts_with(prefix) do
    Trie.GenServerStore.handle_starts_with(prefix)
  end
end

# Your functions will be called as such:
# Trie.init_()
# Trie.insert(word)
# param_2 = Trie.search(word)
# param_3 = Trie.starts_with(prefix)

# Trie.init_ will be called before every test case, in which you can do some necessary initializations.
