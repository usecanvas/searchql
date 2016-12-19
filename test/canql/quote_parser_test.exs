defmodule CanQL.QuoteParserTest do
  use ExUnit.Case, async: true

  doctest CanQL.QuoteParser

  alias CanQL.QuoteParser

  test "parses basic quotes" do
    assert QuoteParser.parse([data: ~s("foo bar")]) ==
      [quote: ~s(foo bar)]
      [{:quote, ~s(foo bar)}]
  end

  test "parses quotes and non-quotes" do
    assert QuoteParser.parse([data: ~s(foo "bar baz" qux)]) ==
      [data: "foo ", quote: "bar baz", data: " qux"]
  end
end
