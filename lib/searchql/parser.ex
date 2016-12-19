defmodule SearchQL.Parser do
  @moduledoc """
  A behaviour that defines how to build parsers for SearchQL. A SearchQL parser
  must expose a single `parse/1` function that accepts an array of SearchQL
  tokens and returns an array of SearchQL tokens.
  """

  @callback parse([SearchQL.token]) :: [SearchQL.token]
end
