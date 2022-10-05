defmodule Trie.Tests do
  use ExUnit.Case

  describe "trie test" do
    # mix test lib/trie/trie_test.exs
    test "" do
      Trie.init_()
    end
  end

  describe "match_size test" do
    test "word_and_keyword_is_same" do
      assert {:word_and_keyword_is_same, 5, {"", ""}} = Trie.Logic.match_size("hello", "hello")
    end

    test "keyword_include_in_word" do
      assert {:keyword_include_in_word, 3, {"lo", ""}} = Trie.Logic.match_size("hello", "hel")
    end

    test "word_include_in_keyword" do
      assert {:word_include_in_keyword, 3, {"", "lo"}} = Trie.Logic.match_size("hel", "hello")
    end

    test "not_match" do
      assert {:not_match, 0, {"hello", "world"}} = Trie.Logic.match_size("hello", "world")
    end

    test "some_match" do
      assert {:some_match, 3, {"lo", " hound"}} = Trie.Logic.match_size("hello", "hel hound")
    end
  end

  test "" do
    search_result = Trie.Logic.search(%Trie.Word{}, "hello")
    assert search_result.result == :not_exist
    assert search_result.rest_word == "hello"
    assert search_result.origin_word == "hello"
    assert search_result.word_path == []
    assert search_result.match_detail == nil
  end

  test "insert tets" do
    word_list = ["hello", "hello_parser", "hel", "hello_ppppp", "world"]
    base = word_list |> Enum.reduce(%Trie.Word{}, &Trie.Logic.insert(&2, &1))

    word_list
    |> Enum.map(fn word ->
      search_result = base |> Trie.Logic.search(word)
      assert search_result.result == :exist
    end)

    search_result = base |> Trie.Logic.search("hello_pa")
    assert search_result.result == :not_exist
    assert base |> Trie.Logic.starts_with("hello_pa") == true

    search_result = base |> Trie.Logic.search("he")
    assert search_result.result == :not_exist
    assert base |> Trie.Logic.starts_with("he") == true

    t = %Trie.Word{
      keyword: nil,
      origin_word: nil,
      is_complete_word: false,
      head_keyset: MapSet.new(["h", "w"]),
      head_keyset_mapping: %{"h" => "hel", "w" => "world"},
      store: %{
        "hel" => %Trie.Word{
          keyword: "hel",
          origin_word: "hel",
          is_complete_word: true,
          head_keyset: MapSet.new(["l"]),
          head_keyset_mapping: %{"l" => "lo"},
          store: %{
            "lo" => %Trie.Word{
              keyword: "lo",
              origin_word: "hello",
              is_complete_word: true,
              head_keyset: MapSet.new(["_"]),
              head_keyset_mapping: %{"_" => "_p"},
              store: %{
                "_p" => %Trie.Word{
                  keyword: "_p",
                  origin_word: nil,
                  is_complete_word: false,
                  head_keyset: MapSet.new(["a", "p"]),
                  head_keyset_mapping: %{"a" => "arser", "p" => "pppp"},
                  store: %{
                    "arser" => %Trie.Word{
                      keyword: "arser",
                      origin_word: "hello_parser",
                      is_complete_word: true,
                      head_keyset: MapSet.new([]),
                      head_keyset_mapping: %{},
                      store: %{}
                    },
                    "pppp" => %Trie.Word{
                      keyword: "pppp",
                      origin_word: "hello_ppppp",
                      is_complete_word: true,
                      head_keyset: MapSet.new([]),
                      head_keyset_mapping: %{},
                      store: %{}
                    }
                  }
                }
              }
            }
          }
        },
        "world" => %Trie.Word{
          keyword: "world",
          origin_word: "world",
          is_complete_word: true,
          head_keyset: MapSet.new([]),
          head_keyset_mapping: %{},
          store: %{}
        }
      }
    }
  end

  describe "Trie init test" do
    test "Trie init!" do
      Trie.init_()
      assert Trie.search("a")
      word_list = ["hello", "hello_parser", "hel", "hello_ppppp", "world", "hwp"]
      word_list |> Enum.map(&Trie.insert(&1))

      word_list
      |> Enum.map(fn word ->
        assert Trie.search(word)
      end)
    end

    test "trie2" do
      Trie.init_()
    end
  end
end
