defmodule Trie.GenServerStore do
  use GenServer

  def handle_insert(word) do
    GenServer.call(__MODULE__, {:insert, word})
  end

  def handle_search(word) do
    GenServer.call(__MODULE__, {:search, word})
  end

  def handle_starts_with(word) do
    GenServer.call(__MODULE__, {:starts_with, word})
  end

  def start_link() do
    case GenServer.whereis(__MODULE__) do
      nil ->
        :ok

      _ ->
        GenServer.stop(__MODULE__, :normal)
    end

    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok,
     %{
       base_trie: %Trie.Word{}
     }}
  end

  def handle_call({:insert, word}, _from, state) do
    {:reply, :ok,
     %{
       state
       | base_trie: Trie.Logic.insert(state.base_trie, word)
     }}
  end

  def handle_call({:search, word}, _from, %{base_trie: trie} = state) do
    search_word_result = Trie.Logic.search(trie, word)
    {:reply, search_word_result.result == :exist, state}
  end

  def handle_call({:starts_with, word}, _from, %{base_trie: trie} = state) do
    {:reply, Trie.Logic.starts_with(trie, word), state}
  end
end
