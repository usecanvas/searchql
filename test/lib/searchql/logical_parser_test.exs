defmodule SearchQL.LogicalParserTest do
  use ExUnit.Case, async: true

  doctest SearchQL.LogicalParser

  alias SearchQL.{LogicalParser, QuoteParser}

  test "ignores non-logical expressions" do
    assert LogicalParser.parse([data: "foo bar"]) == [data: "foo bar"]
  end

  test "parses OR expressions" do
    ~s(foo "bar baz" qux OR hi)
    assert LogicalParser.parse([{:data, "foo OR bar baz"}]) ==
      [or: {[data: "foo"], [data: "bar baz"]}]
  end

  test "parses OR as left-associative" do
    assert LogicalParser.parse([{:data, "foo bar OR baz OR qux"}]) ==
      [or: {
        [or: {[data: "foo bar"], [data: "baz"]}],
        [data: "qux"]}]
  end

  test "parses AND expressions" do
    assert LogicalParser.parse([{:data, "foo AND bar"}]) ==
      [and: {[data: "foo"], [data: "bar"]}]
  end

  test "parses AND as left-associative" do
    assert LogicalParser.parse([{:data, "foo AND bar AND baz"}]) ==
      [and: {
        [and: {
          [data: "foo"],
          [data: "bar"]}],
        [data: "baz"]}]
  end

  test "parses AND with higher precedence than OR" do
    assert LogicalParser.parse([{:data, "foo OR bar AND baz qux"}]) ==
      [or: {
        [data: "foo"],
        [and: {
          [data: "bar"],
          [data: "baz qux"]}]}]
  end

  test "parses already-parsed expressions" do
    query =
       [{:data, ~s(foo "bar baz" OR qux "quux corge")}]
       |> QuoteParser.parse

    assert LogicalParser.parse(query) ==
      [or: {
        [data: "foo", quote: "bar baz"],
        [data: "qux", quote: "quux corge"]}]
  end

  test "parses NOT" do
    assert LogicalParser.parse([data: "foo AND NOT bar"]) ==
      [and: {
        [data: "foo"],
        [not: {[data: "bar"]}]}]
  end

  test "parses NOT with higher binding than OR" do
    assert LogicalParser.parse([data: "foo AND NOT bar OR baz"]) ==
      [or: {
        [and: {
          [data: "foo"],
          [not: {[data: "bar"]}]}],
        [data: "baz"]}]
  end
end
