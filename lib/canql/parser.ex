defmodule CanQL.Parser do
  @moduledoc """
  A behaviour that defines how to build parsers for CanQL. A CanQL parser must
  expose a single `parse/1` function that accepts an array of CanQL tokens and
  returns an array of CanQL tokens.
  """

  @callback parse([CanQL.token]) :: [CanQL.token]
end
