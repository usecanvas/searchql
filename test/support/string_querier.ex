defmodule CanQL.StringQuerier do
  @behaviour CanQL.Querier

  @spec data(String.t, String.t) :: boolean
  def data(string, data), do: String.contains?(data, string)

  @spec quote(String.t, String.t) :: boolean
  def quote(string, data), do: data(string, data)
end
