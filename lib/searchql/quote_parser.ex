defmodule SearchQL.QuoteParser do
  @moduledoc """
  A parser for quotes in SearchQL queries.
  """

  @behaviour SearchQL.Parser

  @doc """
  Parse a list of tokens for quotes

      iex> SearchQL.QuoteParser.parse([{:data, ~s("foo")}])
      [{:quote, "foo"}]
  """
  @spec parse([SearchQL.token]) :: [SearchQL.token]
  def parse(tokens), do: do_parse(tokens)

  @spec do_parse([SearchQL.token], [SearchQL.token]) :: [SearchQL.token]
  defp do_parse(tokens, result \\ [])
  defp do_parse([], result), do: Enum.reverse(result)
  defp do_parse([{:data, data} | tokens], result) do
    new_tokens = parse_quote(data, [])
    do_parse(tokens, new_tokens ++ result)
  end
  defp do_parse([token | tokens], result),
    do: do_parse(tokens, [token | result])

  @spec parse_quote(String.t, [SearchQL.token], SearchQL.token)
    :: [SearchQL.token]
  defp parse_quote(string, tokens, state \\ {:data, ""})
  defp parse_quote("", tokens, {_, ""}), do: tokens
  defp parse_quote("", tokens, state), do: [state | tokens]
  defp parse_quote(~s(") <> string, tokens, token = {:data, data}) do
    tokens = if String.length(data) < 1, do: tokens, else: [token | tokens]
    parse_quote(string, tokens, {:quote, ""})
  end
  defp parse_quote(<<char::binary-size(1), string::binary>>, tokens, {:data, data}),
    do: parse_quote(string, tokens, {:data, data <> char})
  defp parse_quote(~s(") <> string, tokens, qte = {:quote, _}),
    do: parse_quote(string, [qte | tokens], {:data, ""})
  defp parse_quote(<<char::binary-size(1), string::binary>>, tokens, {:quote, qte}),
    do: parse_quote(string, tokens, {:quote, qte <> char})
end
