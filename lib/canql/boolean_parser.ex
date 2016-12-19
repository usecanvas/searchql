defmodule CanQL.BooleanParser do
  @moduledoc """
  Parses boolean expressions in a CanQL query.
  """

  @behaviour CanQL.Parser

  @doc """
  Parses a list of tokens and returns that list with boolean expressions
  replaced by boolean tokens.

      iex> CanQL.BooleanParser.parse([{:data, "foo and bar"}])
      [and: {[data: "foo"], [data: "bar"]}]
  """
  @spec parse([CanQL.token]) :: [CanQL.token]
  def parse(tokens) do
    tokens
    |> Enum.reduce([], &make_words/2)
    |> parse_or
  end

  @spec parse_or([CanQL.token], [CanQL.token]) :: [CanQL.token]
  defp parse_or(tokens, result \\ [])

  defp parse_or([], result) do
    result
    |> Enum.reverse
    |> parse_and
  end

  defp parse_or([{:word, word} | tokens], result) when word in ~w(or OR) do
    [{:or, {parse_or(tokens), parse_or([], result)}}]
  end

  defp parse_or([token | tokens], result) do
    parse_or(tokens, [token | result])
  end

  @spec parse_and([CanQL.token], [CanQL.token]) :: [CanQL.token]
  defp parse_and(tokens, result \\ [])

  defp parse_and([], result) do
    result
    |> Enum.reduce([], &join_words/2)
    |> Enum.reverse
  end

  defp parse_and([{:word, word} | tokens], result) when word in ~w(and AND) do
    [{:and, {parse_and(tokens), parse_and([], result)}}]
  end

  defp parse_and([token | tokens], result) do
    parse_and(tokens, [token | result])
  end

  @spec make_words(CanQL.token, [CanQL.token]) :: [CanQL.token]
  defp make_words({:data, data}, tokens) do
    new_tokens =
      data
      |> String.split(~r/\s+/, trim: true)
      |> Enum.map(&({:word, &1}))
      |> Enum.reverse
    new_tokens ++ tokens
  end

  defp make_words(token, tokens) do
    [token | tokens]
  end

  @spec join_words(CanQL.token, [CanQL.token]) :: [CanQL.token]
  defp join_words({:word, word}, [{type, head_word} | tokens]) when type in [:data, :word] do
    [{:data, "#{head_word} #{word}"} | tokens]
  end

  defp join_words({:word, word}, tokens), do: [{:data, word} | tokens]

  defp join_words(token, tokens), do: [token | tokens]
end
