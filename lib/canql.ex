defmodule CanQL do
  @moduledoc """
  A parser for the Canvas Query Language—a syntax for searching and filtering
  Canvas documents.
  """

  @type tree :: [leaf]
  @type leaf :: {atom, [String.t | leaf]}

  @doc """
  Return whether a query matches data using a given module.
  """
  @spec matches?(String.t, any, atom) :: boolean
  def matches?(query_string, data, mod) do
    {:query, [{tip, args}]} = parse(query_string)
    {:query, [leaf]} = parse(query_string)
    leaf_matches?(leaf, data, mod)
  end

  @spec leaf_matches?(leaf, any, atom) :: boolean
  defp leaf_matches?({:and, [leaf_a, leaf_b]}, data, mod),
    do: leaf_matches?(leaf_a, data, mod) and leaf_matches?(leaf_b, data, mod)
  defp leaf_matches?({:or, [leaf_a, leaf_b]}, data, mod),
    do: leaf_matches?(leaf_a, data, mod) or leaf_matches?(leaf_b, data, mod)
  defp leaf_matches?({func, args}, data, mod),
    do: apply(mod, func, [{args, data}])

  @doc """
  Parse a query string into a tree that can be iterated over in order to
  evaluate the query against data.

      iex> CanQL.parse(~s(foo OR bar))
      {:query, [or: [has: ["foo"], has: ["bar"]]]}
  """
  @spec parse(String.t) :: {:query, tree}
  def parse(query_string) do
    leaf =
      query_string
      |> String.split(~r/\s+/)
      |> Enum.reverse
      |> do_parse

    {:query, [leaf]}
  end

  @spec do_parse([String.t], [leaf]) :: leaf
  defp do_parse(tokens, tree \\ [])

  defp do_parse([], tree),
    do: parse_or(tree)
  defp do_parse(["AND" | tokens], tree),
    do: {:and, [do_parse(tokens), do_parse(tree)]}
  defp do_parse([word | query], tree),
    do: do_parse(query, tree ++ [word])

  @spec parse_or([String.t], [leaf]) :: leaf
  defp parse_or(tokens, tree \\ [])

  defp parse_or([], tree),
    do: parse_text(tree)
  defp parse_or(["OR" | tokens], tree),
    do: {:or, [parse_or(tokens), parse_or(tree)]}
  defp parse_or([word | tokens], tree),
    do: parse_or(tokens, tree ++ [word])

  @spec parse_text([String.t]) :: leaf
  defp parse_text(tokens),
    do: {:has, [tokens |> Enum.reverse |> Enum.join(" ")]}
end
