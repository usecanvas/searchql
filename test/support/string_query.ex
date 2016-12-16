defmodule CanQL.StringQuery do
  @spec has({[String.t], String.t}) :: boolean
  def has({[string], data}), do: String.contains?(data, string)
end
