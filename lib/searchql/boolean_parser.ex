defmodule SearchQL.BooleanParser do
  @moduledoc """
  Parses boolean expressions in a SearchQL query.
  """

  @behaviour SearchQL.Parser

  @doc """
  Parses a list of tokens and returns that list with boolean expressions
  replaced by boolean tokens.

      iex> SearchQL.BooleanParser.parse([data: "foo and bar"])
      [and: {[data: "foo"], [data: "bar"]}]

  This function parses tokens in reverse order, "OR"s before "AND"s. This
  results in a parsing where "AND" has the higher precedence, and where operator
  precedence is left-associative:

      iex> SearchQL.BooleanParser.parse([data: "foo or bar and baz and qux"])
      [or: {
        [data: "foo"],
        [and: {
          [and: {
            [data: "bar"],
            [data: "baz"]}],
          [data: "qux"]}]}]
  """
  @spec parse([SearchQL.token]) :: [SearchQL.token]
  def parse(tokens), do: tokens |> Enum.reduce([], &make_words/2) |> parse_or

  @spec parse_or([SearchQL.token], [SearchQL.token]) :: [SearchQL.token]
  defp parse_or(tokens, result \\ [])
  defp parse_or([], result), do: result |> Enum.reverse |> parse_and
  defp parse_or([{:word, word} | tokens], result) when word in ~w(or OR),
    do: [{:or, {parse_or(tokens), parse_or([], result)}}]
  defp parse_or([token | tokens], result),
    do: parse_or(tokens, [token | result])

  @spec parse_and([SearchQL.token], [SearchQL.token]) :: [SearchQL.token]
  defp parse_and(tokens, result \\ [])
  defp parse_and([], result),
    do: result |> Enum.reduce([], &join_words/2) |> Enum.reverse
  defp parse_and([{:word, word} | tokens], result) when word in ~w(and AND),
    do: [{:and, {parse_and(tokens), parse_and([], result)}}]
  defp parse_and([token | tokens], result),
    do: parse_and(tokens, [token | result])

  @spec make_words(SearchQL.token, [SearchQL.token]) :: [SearchQL.token]
  defp make_words({:data, data}, tokens) do
    data
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&({:word, &1}))
    |> Enum.reverse
    |> Enum.concat(tokens)
  end

  defp make_words(token, tokens), do: [token | tokens]

  @spec join_words(SearchQL.token, [SearchQL.token]) :: [SearchQL.token]
  defp join_words({:word, word}, [{type, head_word} | tokens]) when type in [:data, :word],
    do: [{:data, "#{head_word} #{word}"} | tokens]
  defp join_words({:word, word}, tokens), do: [{:data, word} | tokens]
  defp join_words(token, tokens), do: [token | tokens]
end
