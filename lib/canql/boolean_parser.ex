defmodule CanQL.BooleanParser do
  @moduledoc """
  Parses boolean expressions in a CanQL query.
  """

  @doc """
  Parses a list of tokens and returns that list with boolean expressions
  replaced by boolean tokens.

      iex> CanQL.BooleanParser.parse([{:data, "foo and bar"}])
      [{:and, {{:data, "foo"}, {:data, "bar"}}}]
  """
  @spec parse([CanQL.token]) :: [CanQL.token]
  def parse(tokens), do: do_parse(tokens)

  @spec do_parse([CanQL.token], [CanQL.token]) :: [CanQL.token]
  defp do_parse(tokens, result \\ [])
  defp do_parse([], result), do: result

  defp do_parse([{:data, data} | tokens], result) do
    token = data |> words |> Enum.reverse |> parse_or
    do_parse(tokens, [token | result])
  end

  defp do_parse([token | tokens], result),
    do: do_parse(tokens, [token | result])

  @spec parse_or([String.t], [String.t]) :: CanQL.token
  defp parse_or(words, data_words \\ [])
  defp parse_or([], data_words), do: data_words |> Enum.reverse |> parse_and
  defp parse_or([word | words], data_words) when word in ~w(or OR),
    do: {:or, {parse_or(words), parse_or([], data_words)}}
  defp parse_or([word | words], data_words),
    do: parse_or(words, [word | data_words])

  @spec parse_and([String.t], [String.t]) :: CanQL.token
  defp parse_and(words, data_words \\ [])
  defp parse_and([], data_words), do: {:data, Enum.join(data_words, " ")}
  defp parse_and([word | words], data_words) when word in ~w(and AND),
    do: {:and, {parse_and(words), parse_and([], data_words)}}
  defp parse_and([word | words], data_words),
    do: parse_and(words, [word | data_words])

  @spec words(String.t) :: [String.t]
  defp words(string), do: String.split(string, ~r/\s+/)
end
