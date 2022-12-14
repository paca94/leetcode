defmodule Trie.Logic do
  @word_and_keyword_is_same :word_and_keyword_is_same
  @word_include_in_keyword :word_include_in_keyword
  @keyword_include_in_word :keyword_include_in_word
  @not_match :not_match
  @some_match :some_match
  @spec insert(
          %Trie.Word{},
          binary
        ) :: %Trie.Word{}
  def insert(%Trie.Word{} = trie, word) do
    word_search_result = search(trie, word)
    insert(trie, word_search_result, word_search_result.word_path)
  end

  @spec search(%Trie.Word{}, String.t()) ::
          %Trie.WordSearchResult{
            match_detail:
              nil
              | {:some_match, pos_integer, {String.t(), String.t()}}
              | {:word_and_keyword_is_same, non_neg_integer, {String.t(), String.t()}}
              | {:word_include_in_keyword, non_neg_integer, {String.t(), String.t()}},
            origin_word: String.t(),
            rest_word: String.t(),
            result: :exist | :not_exist,
            word_path: list(String.t())
          }
  def search(%Trie.Word{} = trie, word) do
    word_search_result = search(trie, word, word, [])

    %Trie.WordSearchResult{
      word_search_result
      | word_path: Enum.reverse(word_search_result.word_path)
    }
  end

  def starts_with(%Trie.Word{} = trie, word) do
    search_word_result = search(trie, word)

    case {search_word_result.result, search_word_result.match_detail} do
      {:exist, _} -> true
      {:not_exist, {@word_and_keyword_is_same, _, _}} -> true
      {:not_exist, {@word_include_in_keyword, _, _}} -> true
      _ -> false
    end
  end

  ### private methods

  defp insert(
         %Trie.Word{} = trie,
         %Trie.WordSearchResult{result: :exist} = _search_result,
         _word_path
       ) do
    trie
  end

  defp insert(
         %Trie.Word{} = trie,
         %Trie.WordSearchResult{} = search_result,
         [current_path_word | rest_word_path] = _word_path
       ) do
    %Trie.Word{
      trie
      | store:
          Map.put(
            trie.store,
            current_path_word,
            insert(trie.store[current_path_word], search_result, rest_word_path)
          )
    }
  end

  defp insert(%Trie.Word{} = trie, %Trie.WordSearchResult{} = search_result, [] = _word_path) do
    {search_result.result, search_result.match_detail} |> insert_internal!(search_result, trie)
  end

  defp insert_internal!(
         {:not_exist, nil},
         %Trie.WordSearchResult{} = search_result,
         %Trie.Word{} = trie
       ) do
    new_trie = %Trie.Word{
      keyword: search_result.rest_word,
      origin_word: search_result.origin_word,
      is_complete_word: true
    }

    Trie.Word.append_trie(trie, new_trie)
  end

  defp insert_internal!(
         {:not_exist, {@word_and_keyword_is_same, _, _}},
         %Trie.WordSearchResult{} = search_result,
         %Trie.Word{} = trie
       ) do
    search_trie = trie.store[search_result.rest_word]

    search_trie = %Trie.Word{
      search_trie
      | origin_word: search_result.origin_word,
        is_complete_word: true
    }

    %Trie.Word{
      trie
      | store: Map.put(trie.store, search_result.rest_word, search_trie)
    }
  end

  defp insert_internal!(
         {:not_exist, {@word_include_in_keyword, _, {_, match_rest_keyword}}},
         %Trie.WordSearchResult{} = search_result,
         %Trie.Word{} = trie
       ) do
    # ????????? ????????????, ????????? trie??? ???????????? ????????????????????? ?????? trie??? ???????????????..
    first_char = String.first(search_result.rest_word)
    search_word = trie.head_keyset_mapping[first_char]

    previous_exist_trie = trie.store[search_word]

    previous_exist_trie = %Trie.Word{
      previous_exist_trie
      | keyword: match_rest_keyword
    }

    new_trie = %Trie.Word{
      keyword: search_result.rest_word,
      origin_word: search_result.origin_word,
      is_complete_word: true
    }

    # ???????????? trie??? ?????? trie ??????
    new_trie = Trie.Word.append_trie(new_trie, previous_exist_trie)
    # ?????? trie??? ???????????? trie ??????
    trie
    |> Trie.Word.delete_by_key(search_word)
    |> Trie.Word.append_trie(new_trie)
  end

  # @some_match :some_match
  defp insert_internal!(
         {:not_exist, {@some_match, match_size, {match_rest_word, match_rest_keyword}}},
         %Trie.WordSearchResult{} = search_result,
         %Trie.Word{} = trie
       ) do
    # ????????? ????????????, ????????? trie??? ???????????? ????????????????????? ?????? trie??? ???????????????..
    with first_char <- String.first(search_result.rest_word),
         search_word <- trie.head_keyset_mapping[first_char],
         previous_exist_trie <- trie.store[search_word],
         previous_exist_trie <- %Trie.Word{
           previous_exist_trie
           | keyword: match_rest_keyword
         },
         # new trie
         new_trie <- %Trie.Word{
           keyword: match_rest_word,
           origin_word: search_result.origin_word,
           is_complete_word: true
         },
         # ???????????? ?????? trie
         new_base_keyword <- String.slice(search_result.rest_word, 0..(match_size - 1)),
         new_base_trie <- %Trie.Word{
           keyword: new_base_keyword,
           origin_word: nil,
           is_complete_word: false
         } do
      # ???????????? trie??? ?????? trie ??????
      new_base_trie =
        new_base_trie
        |> Trie.Word.append_trie(previous_exist_trie)
        |> Trie.Word.append_trie(new_trie)

      # ?????? trie??? ???????????? trie ??????
      trie
      |> Trie.Word.delete_by_key(search_word)
      |> Trie.Word.append_trie(new_base_trie)
    end
  end

  defp insert_internal!(
         {:not_exist, {@not_match, _, _}},
         %Trie.WordSearchResult{} = _search_result,
         %Trie.Word{} = _trie
       ) do
    raise {:error, :insert_internal}
  end

  # @not_match :not_match

  defp search(%Trie.Word{head_keyset: head_keyset} = trie, rest_word, origin_word, word_path) do
    first_char = String.first(rest_word)

    case MapSet.member?(head_keyset, first_char) do
      false ->
        # ?????????
        %Trie.WordSearchResult{
          rest_word: rest_word,
          origin_word: origin_word,
          word_path: word_path,
          result: :not_exist,
          match_detail: nil
        }

      true ->
        search_word = trie.head_keyset_mapping[first_char]
        search_trie = trie.store[search_word]
        match_detail = match_size(rest_word, search_trie.keyword)

        case match_detail do
          {@word_and_keyword_is_same, _, _} ->
            # ?????????, complete word?????????
            # complete word??? ????????????
            search_result =
              case search_trie.is_complete_word do
                true ->
                  :exist

                false ->
                  :not_exist
              end

            next_word_path =
              case search_trie.is_complete_word do
                true ->
                  [search_trie.keyword | word_path]

                false ->
                  word_path
              end

            %Trie.WordSearchResult{
              rest_word: rest_word,
              origin_word: origin_word,
              word_path: next_word_path,
              result: search_result,
              match_detail: match_detail
            }

          {@word_include_in_keyword, _, _} ->
            # ?????? ????????? ???????????? ?????????. ???, ???????????? ??????. ( ?????? ????????? ??? ?????? ?????? )
            %Trie.WordSearchResult{
              rest_word: rest_word,
              origin_word: origin_word,
              word_path: word_path,
              result: :not_exist,
              match_detail: match_detail
            }

          {@keyword_include_in_word, _, {rest_word, _}} ->
            # ???????????? ????????? ?????????. ???, ??? ?????? ????????????????????? ( ?????? ????????? ??? ??? ?????? )

            search(search_trie, rest_word, origin_word, [search_trie.keyword | word_path])

          {@some_match, _, _} ->
            # ?????? ????????? ??????, ???????????????.
            %Trie.WordSearchResult{
              rest_word: rest_word,
              origin_word: origin_word,
              word_path: word_path,
              result: :not_exist,
              match_detail: match_detail
            }

            # ?????? ???????????? ????????? ??? ??????
            # {@not_match, _, _} -> {:error, :shold_not_occur}
        end
    end
  end

  @spec match_size(String.t(), String.t()) ::
          {:word_and_keyword_is_same, non_neg_integer, {String.t(), String.t()}}
          | {:word_include_in_keyword, non_neg_integer, {String.t(), String.t()}}
          | {:keyword_include_in_word, non_neg_integer, {String.t(), String.t()}}
          | {:not_match, non_neg_integer, {String.t(), String.t()}}
          | {:some_match, non_neg_integer, {String.t(), String.t()}}
  def match_size(word, key_word) do
    match_size(word, key_word, 0)
  end

  defp match_size(
         <<>> = word,
         <<>> = keyword,
         current_match_size
       ) do
    {@word_and_keyword_is_same, current_match_size, {word, keyword}}
  end

  defp match_size(
         <<>> = word,
         _ = keyword,
         current_match_size
       ) do
    {@word_include_in_keyword, current_match_size, {word, keyword}}
  end

  defp match_size(
         _ = word,
         <<>> = keyword,
         current_match_size
       ) do
    {@keyword_include_in_word, current_match_size, {word, keyword}}
  end

  defp match_size(
         word,
         keyword,
         current_match_size
       ) do
    case {String.first(word) == String.first(keyword), current_match_size} do
      {true, _} ->
        match_size(
          String.slice(word, 1..-1),
          String.slice(keyword, 1..-1),
          current_match_size + 1
        )

      {false, 0} ->
        {@not_match, current_match_size, {word, keyword}}

      {false, _} ->
        {@some_match, current_match_size, {word, keyword}}
    end
  end
end
