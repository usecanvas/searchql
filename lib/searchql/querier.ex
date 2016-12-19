defmodule SearchQL.Querier do
  @moduledoc """
  A behaviour that defines how a type piece of data can be queried. A SearchQL
  querier exposes a `data/2` and a `quote/2` function that parse a pure data
  string and query the data, and query the data for a quote, respectively.
  """

  @callback data(String.t, any) :: boolean
  @callback quote(String.t, any) :: boolean
end
