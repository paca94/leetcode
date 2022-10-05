# # https://leetcode.com/problems/implement-trie-prefix-tree/
# # https://leetcode.com/submissions/detail/815807382/
# # 모든 소스코드가 합쳐진 풀파일입니다.

# defmodule Trie.Word do
#   defstruct [
#     :keyword,
#     :origin_word,
#     is_complete_word: false,
#     head_keyset: MapSet.new([]),
#     head_keyset_mapping: %{},
#     store: %{}
#   ]

#   def append_trie(%__MODULE__{} = trie, %__MODULE__{} = next_trie) do
#     first_char = String.first(next_trie.keyword)

#     %__MODULE__{
#       trie
#       | head_keyset: MapSet.put(trie.head_keyset, first_char),
#         head_keyset_mapping: Map.put(trie.head_keyset_mapping, first_char, next_trie.keyword),
#         store: Map.put(trie.store, next_trie.keyword, next_trie)
#     }
#   end

#   def delete_by_key(%__MODULE__{} = trie, del_key) do
#     first_char = String.first(del_key)

#     %__MODULE__{
#       trie
#       | head_keyset: MapSet.delete(trie.head_keyset, first_char),
#         head_keyset_mapping: Map.delete(trie.head_keyset_mapping, first_char),
#         store: Map.delete(trie.store, del_key)
#     }
#   end
# end

# defmodule Trie.WordSearchResult do
#   defstruct [
#     :rest_word,
#     :origin_word,
#     :word_path,
#     :result,
#     :match_detail
#   ]
# end

# defmodule Trie.Logic do
#   @word_and_keyword_is_same :word_and_keyword_is_same
#   @word_include_in_keyword :word_include_in_keyword
#   @keyword_include_in_word :keyword_include_in_word
#   @not_match :not_match
#   @some_match :some_match
#   @spec insert(
#           %Trie.Word{},
#           binary
#         ) :: %Trie.Word{}
#   def insert(%Trie.Word{} = trie, word) do
#     word_search_result = search(trie, word)
#     insert(trie, word_search_result, word_search_result.word_path)
#   end

#   @spec search(%Trie.Word{}, String.t()) ::
#           %Trie.WordSearchResult{
#             match_detail:
#               nil
#               | {:some_match, pos_integer, {String.t(), String.t()}}
#               | {:word_and_keyword_is_same, non_neg_integer, {String.t(), String.t()}}
#               | {:word_include_in_keyword, non_neg_integer, {String.t(), String.t()}},
#             origin_word: String.t(),
#             rest_word: String.t(),
#             result: :exist | :not_exist,
#             word_path: list(String.t())
#           }
#   def search(%Trie.Word{} = trie, word) do
#     word_search_result = search(trie, word, word, [])

#     %Trie.WordSearchResult{
#       word_search_result
#       | word_path: Enum.reverse(word_search_result.word_path)
#     }
#   end

#   def starts_with(%Trie.Word{} = trie, word) do
#     search_word_result = search(trie, word)

#     case {search_word_result.result, search_word_result.match_detail} do
#       {:exist, _} -> true
#       {:not_exist, {@word_and_keyword_is_same, _, _}} -> true
#       {:not_exist, {@word_include_in_keyword, _, _}} -> true
#       _ -> false
#     end
#   end

#   ### private methods

#   defp insert(
#          %Trie.Word{} = trie,
#          %Trie.WordSearchResult{result: :exist} = _search_result,
#          _word_path
#        ) do
#     trie
#   end

#   defp insert(
#          %Trie.Word{} = trie,
#          %Trie.WordSearchResult{} = search_result,
#          [current_path_word | rest_word_path] = _word_path
#        ) do
#     %Trie.Word{
#       trie
#       | store:
#           Map.put(
#             trie.store,
#             current_path_word,
#             insert(trie.store[current_path_word], search_result, rest_word_path)
#           )
#     }
#   end

#   defp insert(%Trie.Word{} = trie, %Trie.WordSearchResult{} = search_result, [] = _word_path) do
#     {search_result.result, search_result.match_detail} |> insert_internal!(search_result, trie)
#   end

#   defp insert_internal!(
#          {:not_exist, nil},
#          %Trie.WordSearchResult{} = search_result,
#          %Trie.Word{} = trie
#        ) do
#     new_trie = %Trie.Word{
#       keyword: search_result.rest_word,
#       origin_word: search_result.origin_word,
#       is_complete_word: true
#     }

#     Trie.Word.append_trie(trie, new_trie)
#   end

#   defp insert_internal!(
#          {:not_exist, {@word_and_keyword_is_same, _, _}},
#          %Trie.WordSearchResult{} = search_result,
#          %Trie.Word{} = trie
#        ) do
#     search_trie = trie.store[search_result.rest_word]

#     search_trie = %Trie.Word{
#       search_trie
#       | origin_word: search_result.origin_word,
#         is_complete_word: true
#     }

#     %Trie.Word{
#       trie
#       | store: Map.put(trie.store, search_result.rest_word, search_trie)
#     }
#   end

#   defp insert_internal!(
#          {:not_exist, {@word_include_in_keyword, _, {_, match_rest_keyword}}},
#          %Trie.WordSearchResult{} = search_result,
#          %Trie.Word{} = trie
#        ) do
#     # 단위가 작으므로, 새로운 trie를 만들어서 리플레이스하고 기존 trie를 넣어줘야함..
#     first_char = String.first(search_result.rest_word)
#     search_word = trie.head_keyset_mapping[first_char]

#     previous_exist_trie = trie.store[search_word]

#     previous_exist_trie = %Trie.Word{
#       previous_exist_trie
#       | keyword: match_rest_keyword
#     }

#     new_trie = %Trie.Word{
#       keyword: search_result.rest_word,
#       origin_word: search_result.origin_word,
#       is_complete_word: true
#     }

#     # 새로만든 trie에 기존 trie 붙임
#     new_trie = Trie.Word.append_trie(new_trie, previous_exist_trie)
#     # 부모 trie에 새로만든 trie 붙임
#     trie
#     |> Trie.Word.delete_by_key(search_word)
#     |> Trie.Word.append_trie(new_trie)
#   end

#   # @some_match :some_match
#   defp insert_internal!(
#          {:not_exist, {@some_match, match_size, {match_rest_word, match_rest_keyword}}},
#          %Trie.WordSearchResult{} = search_result,
#          %Trie.Word{} = trie
#        ) do
#     # 단위가 작으므로, 새로운 trie를 만들어서 리플레이스하고 기존 trie를 넣어줘야함..
#     with first_char <- String.first(search_result.rest_word),
#          search_word <- trie.head_keyset_mapping[first_char],
#          previous_exist_trie <- trie.store[search_word],
#          previous_exist_trie <- %Trie.Word{
#            previous_exist_trie
#            | keyword: match_rest_keyword
#          },
#          # new trie
#          new_trie <- %Trie.Word{
#            keyword: match_rest_word,
#            origin_word: search_result.origin_word,
#            is_complete_word: true
#          },
#          # 베이스가 되는 trie
#          new_base_keyword <- String.slice(search_result.rest_word, 0..(match_size - 1)),
#          new_base_trie <- %Trie.Word{
#            keyword: new_base_keyword,
#            origin_word: nil,
#            is_complete_word: false
#          } do
#       # 새로만든 trie에 기존 trie 붙임
#       new_base_trie =
#         new_base_trie
#         |> Trie.Word.append_trie(previous_exist_trie)
#         |> Trie.Word.append_trie(new_trie)

#       # 부모 trie에 새로만든 trie 붙임
#       trie
#       |> Trie.Word.delete_by_key(search_word)
#       |> Trie.Word.append_trie(new_base_trie)
#     end
#   end

#   defp insert_internal!(
#          {:not_exist, {@not_match, _, _}},
#          %Trie.WordSearchResult{} = _search_result,
#          %Trie.Word{} = _trie
#        ) do
#     raise {:error, :insert_internal}
#   end

#   # @not_match :not_match

#   defp search(%Trie.Word{head_keyset: head_keyset} = trie, rest_word, origin_word, word_path) do
#     first_char = String.first(rest_word)

#     case MapSet.member?(head_keyset, first_char) do
#       false ->
#         # 뉴멤버
#         %Trie.WordSearchResult{
#           rest_word: rest_word,
#           origin_word: origin_word,
#           word_path: word_path,
#           result: :not_exist,
#           match_detail: nil
#         }

#       true ->
#         search_word = trie.head_keyset_mapping[first_char]
#         search_trie = trie.store[search_word]
#         match_detail = match_size(rest_word, search_trie.keyword)

#         case match_detail do
#           {@word_and_keyword_is_same, _, _} ->
#             # 같지만, complete word일경우
#             # complete word가 아닐경우
#             search_result =
#               case search_trie.is_complete_word do
#                 true ->
#                   :exist

#                 false ->
#                   :not_exist
#               end

#             next_word_path =
#               case search_trie.is_complete_word do
#                 true ->
#                   [search_trie.keyword | word_path]

#                 false ->
#                   word_path
#               end

#             %Trie.WordSearchResult{
#               rest_word: rest_word,
#               origin_word: origin_word,
#               word_path: next_word_path,
#               result: search_result,
#               match_detail: match_detail
#             }

#           {@word_include_in_keyword, _, _} ->
#             # 찾는 키값이 키워드에 포함됨. 즉, 존재하진 않음. ( 찾는 단어가 더 작은 단위 )
#             %Trie.WordSearchResult{
#               rest_word: rest_word,
#               origin_word: origin_word,
#               word_path: word_path,
#               result: :not_exist,
#               match_detail: match_detail
#             }

#           {@keyword_include_in_word, _, {rest_word, _}} ->
#             # 키워드가 키값에 포함됨. 즉, 더 깊이 찾아들어가야함 ( 찾는 단어가 더 큰 단위 )

#             search(search_trie, rest_word, origin_word, [search_trie.keyword | word_path])

#           {@some_match, _, _} ->
#             # 찾는 단어가 없고, 부분일치함.
#             %Trie.WordSearchResult{
#               rest_word: rest_word,
#               origin_word: origin_word,
#               word_path: word_path,
#               result: :not_exist,
#               match_detail: match_detail
#             }

#             # 아래 케이스는 일어날 수 없음
#             # {@not_match, _, _} -> {:error, :shold_not_occur}
#         end
#     end
#   end

#   @spec match_size(String.t(), String.t()) ::
#           {:word_and_keyword_is_same, non_neg_integer, {String.t(), String.t()}}
#           | {:word_include_in_keyword, non_neg_integer, {String.t(), String.t()}}
#           | {:keyword_include_in_word, non_neg_integer, {String.t(), String.t()}}
#           | {:not_match, non_neg_integer, {String.t(), String.t()}}
#           | {:some_match, non_neg_integer, {String.t(), String.t()}}
#   def match_size(word, key_word) do
#     match_size(word, key_word, 0)
#   end

#   defp match_size(
#          <<>> = word,
#          <<>> = keyword,
#          current_match_size
#        ) do
#     {@word_and_keyword_is_same, current_match_size, {word, keyword}}
#   end

#   defp match_size(
#          <<>> = word,
#          _ = keyword,
#          current_match_size
#        ) do
#     {@word_include_in_keyword, current_match_size, {word, keyword}}
#   end

#   defp match_size(
#          _ = word,
#          <<>> = keyword,
#          current_match_size
#        ) do
#     {@keyword_include_in_word, current_match_size, {word, keyword}}
#   end

#   defp match_size(
#          word,
#          keyword,
#          current_match_size
#        ) do
#     case {String.first(word) == String.first(keyword), current_match_size} do
#       {true, _} ->
#         match_size(
#           String.slice(word, 1..-1),
#           String.slice(keyword, 1..-1),
#           current_match_size + 1
#         )

#       {false, 0} ->
#         {@not_match, current_match_size, {word, keyword}}

#       {false, _} ->
#         {@some_match, current_match_size, {word, keyword}}
#     end
#   end
# end

# defmodule TrieStateServer do
#   use GenServer

#   def handle_insert(word) do
#     GenServer.call(__MODULE__, {:insert, word})
#   end

#   def handle_search(word) do
#     GenServer.call(__MODULE__, {:search, word})
#   end

#   def handle_starts_with(word) do
#     GenServer.call(__MODULE__, {:starts_with, word})
#   end

#   def start_link() do
#     case GenServer.whereis(__MODULE__) do
#       nil ->
#         :ok

#       _ ->
#         GenServer.stop(__MODULE__, :normal)
#     end

#     GenServer.start_link(__MODULE__, [], name: __MODULE__)
#   end

#   def init(_) do
#     {:ok,
#      %{
#        base_trie: %Trie.Word{}
#      }}
#   end

#   def handle_call({:insert, word}, _from, state) do
#     {:reply, :ok,
#      %{
#        state
#        | base_trie: Trie.Logic.insert(state.base_trie, word)
#      }}
#   end

#   def handle_call({:search, word}, _from, %{base_trie: trie} = state) do
#     search_word_result = Trie.Logic.search(trie, word)
#     {:reply, search_word_result.result == :exist, state}
#   end

#   def handle_call({:starts_with, word}, _from, %{base_trie: trie} = state) do
#     {:reply, Trie.Logic.starts_with(trie, word), state}
#   end
# end

# defmodule Trie do
#   @spec init_() :: any
#   def init_() do
#     TrieStateServer.start_link()
#   end

#   @spec insert(word :: String.t()) :: any
#   def insert(word) do
#     TrieStateServer.handle_insert(word)
#   end

#   @spec search(word :: String.t()) :: boolean
#   def search(word) do
#     TrieStateServer.handle_search(word)
#   end

#   @spec starts_with(prefix :: String.t()) :: boolean
#   def starts_with(prefix) do
#     TrieStateServer.handle_starts_with(prefix)
#   end
# end

# # Your functions will be called as such:
# # Trie.init_()
# # Trie.insert(word)
# # param_2 = Trie.search(word)
# # param_3 = Trie.starts_with(prefix)

# # Trie.init_ will be called before every test case, in which you can do some necessary initializations.
