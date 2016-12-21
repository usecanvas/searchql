defmodule SearchQL do
  @moduledoc """
  A parsed representation of a human-written search query.
  """

  alias SearchQL.{LogicalParser, QuoteParser}

  @type token :: {atom, String.t | {[token], [token]}}

  @doc """
  Return whether a query matches data using a given module.
  """
  @spec matches?(String.t, any, atom) :: boolean
  def matches?(query_string, data, mod),
    do: query_string |> parse |> do_matches?(data, mod)

  @spec do_matches?([SearchQL.token], any, atom) :: boolean
  defp do_matches?(tokens, data, mod) do
    tokens
    |> Enum.reduce_while(true, fn (token, _) ->
      if token_matches?(token, data, mod) do
        {:cont, true}
      else
        {:halt, false}
      end
    end)
  end

  @spec token_matches?(token, any, atom) :: boolean
  defp token_matches?(tokens, data, mod) when is_list(tokens),
    do: do_matches?(tokens, data, mod)
  defp token_matches?({:or, {tok_a, tok_b}}, data, mod),
    do: token_matches?(tok_a, data, mod) or token_matches?(tok_b, data, mod)
  defp token_matches?({:not, {tokens}}, data, mod),
    do: !token_matches?(tokens, data, mod)
  defp token_matches?({func, args}, data, mod),
    do: apply(mod, func, [args, data])

  @doc """
  Parse a query string into a tree that can be iterated over in order to
  evaluate the query against data.

      iex> SearchQL.parse(~s(foo bar baz))
      [{:data, "foo bar baz"}]
  """
  @spec parse(String.t) :: [token]
  def parse(query_string),
    do: [{:data, query_string}] |> QuoteParser.parse |> LogicalParser.parse
end
