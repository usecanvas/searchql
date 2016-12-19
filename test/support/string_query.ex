defmodule CanQL.StringQuery do
  @spec data({String.t, String.t}) :: boolean
  def data({string, data}), do: String.contains?(data, string)
end
