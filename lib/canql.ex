defmodule CanQL do
  @moduledoc """
  A parser for the Canvas Query Language—a syntax for searching and filtering
  Canvas documents.
  """

  alias CanQL.BooleanParser

  @type token :: {atom, String.t | {token, token}}

  @doc """
  Return whether a query matches data using a given module.
  """
  @spec matches?(String.t, any, atom) :: boolean
  def matches?(query_string, data, mod) do
    [token] = parse(query_string)
    token_matches?(token, data, mod)
  end

  @spec token_matches?(token, any, atom) :: boolean
  defp token_matches?({:and, {tok_a, tok_b}}, data, mod),
    do: token_matches?(tok_a, data, mod) and token_matches?(tok_b, data, mod)
  defp token_matches?({:or, {tok_a, tok_b}}, data, mod),
    do: token_matches?(tok_a, data, mod) or token_matches?(tok_b, data, mod)
  defp token_matches?({func, args}, data, mod),
    do: apply(mod, func, [{args, data}])

  @doc """
  Parse a query string into a tree that can be iterated over in order to
  evaluate the query against data.

      iex> CanQL.parse(~s(foo bar baz))
      [{:data, "foo bar baz"}]
  """
  @spec parse(String.t) :: {:query, [token]}
  def parse(query_string) do
    [{:data, query_string}]
    |> BooleanParser.parse
  end
end
