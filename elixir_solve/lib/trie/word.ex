defmodule Trie.Word do
  defstruct [
    :keyword,
    :origin_word,
    is_complete_word: false,
    head_keyset: MapSet.new([]),
    head_keyset_mapping: %{},
    store: %{}
  ]

  def append_trie(%__MODULE__{} = trie, %__MODULE__{} = next_trie) do
    first_char = String.first(next_trie.keyword)

    %__MODULE__{
      trie
      | head_keyset: MapSet.put(trie.head_keyset, first_char),
        head_keyset_mapping: Map.put(trie.head_keyset_mapping, first_char, next_trie.keyword),
        store: Map.put(trie.store, next_trie.keyword, next_trie)
    }
  end

  def delete_by_key(%__MODULE__{} = trie, del_key) do
    first_char = String.first(del_key)

    %__MODULE__{
      trie
      | head_keyset: MapSet.delete(trie.head_keyset, first_char),
        head_keyset_mapping: Map.delete(trie.head_keyset_mapping, first_char),
        store: Map.delete(trie.store, del_key)
    }
  end
end
