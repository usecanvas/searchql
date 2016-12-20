defmodule SearchQLTest do
  use ExUnit.Case

  doctest SearchQL

  alias SearchQL.StringQuerier

  describe ".matches?/2" do
    test "matches basic string" do
      assert SearchQL.matches?(~s(foo bar), "foo bar baz", StringQuerier)
      refute SearchQL.matches?(~s(foo bar), "foo baz baz", StringQuerier)
    end

    test "matches basic OR" do
      assert SearchQL.matches?(~s(foo OR bar), "foo", StringQuerier)
      assert SearchQL.matches?(~s(foo OR bar), "bar", StringQuerier)
      refute SearchQL.matches?(~s(foo OR bar), "baz", StringQuerier)
    end

    test "matches multiple OR" do
      assert SearchQL.matches?(~s(foo OR bar OR baz), "foo", StringQuerier)
      assert SearchQL.matches?(~s(foo OR bar OR baz), "bar", StringQuerier)
      refute SearchQL.matches?(~s(foo OR bar OR baz), "qux", StringQuerier)
    end

    test "matches basic AND" do
      assert SearchQL.matches?(~s(foo AND bar), "foo bar", StringQuerier)
      refute SearchQL.matches?(~s(foo AND bar), "foo baz", StringQuerier)
    end

    test "matches multiple AND" do
      assert SearchQL.matches?(~s(foo AND bar AND baz), "foo bar baz", StringQuerier)
      refute SearchQL.matches?(~s(foo AND bar AND baz), "foo bar qux", StringQuerier)
    end

    test "matches combination AND and OR" do
      assert SearchQL.matches?(
        ~s(foo OR bar AND baz AND qux OR foo2 OR bar2),
        ~s(bar lala baz qux),
        StringQuerier)
    end

    test "matches quotes" do
      assert SearchQL.matches?(
        ~s(foo "bar baz"),
        ~s(foo bar baz qux),
        StringQuerier)

      refute SearchQL.matches?(
        ~s(foo "bar baz qux" fooo),
        ~s(foo bar baz qux),
        StringQuerier)
    end

    test "matches mixed quotes and bools" do
      query = ~s("foo bar" OR "foo baz" AND qux)
      assert SearchQL.matches?(query, "foo bar qux", StringQuerier)
    end
  end

  describe ".parse/1" do
    test "parses combined logical and quotes" do
      assert SearchQL.parse(~s("foo bar" AND baz)) ==
        [and: {[quote: "foo bar"], [data: "baz"]}]
    end
  end
end
