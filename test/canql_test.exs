defmodule CanQLTest do
  use ExUnit.Case

  doctest CanQL

  alias CanQL.StringQuery

  describe ".matches?/2" do
    test "matches basic string" do
      assert CanQL.matches?(~s(foo bar), "foo bar baz", StringQuery)
      refute CanQL.matches?(~s(foo bar), "foo baz baz", StringQuery)
    end

    test "matches basic OR" do
      assert CanQL.matches?(~s(foo OR bar), "foo", StringQuery)
      assert CanQL.matches?(~s(foo OR bar), "bar", StringQuery)
      refute CanQL.matches?(~s(foo OR bar), "baz", StringQuery)
    end

    test "matches multiple OR" do
      assert CanQL.matches?(~s(foo OR bar OR baz), "foo", StringQuery)
      assert CanQL.matches?(~s(foo OR bar OR baz), "bar", StringQuery)
      refute CanQL.matches?(~s(foo OR bar OR baz), "qux", StringQuery)
    end

    test "matches basic AND" do
      assert CanQL.matches?(~s(foo AND bar), "foo bar", StringQuery)
      refute CanQL.matches?(~s(foo AND bar), "foo baz", StringQuery)
    end

    test "matches multiple AND" do
      assert CanQL.matches?(~s(foo AND bar AND baz), "foo bar baz", StringQuery)
      refute CanQL.matches?(~s(foo AND bar AND baz), "foo bar qux", StringQuery)
    end

    test "matches combination AND and OR" do
      assert CanQL.matches?(
        ~s(foo OR bar AND baz AND qux OR foo2 OR bar2),
        ~s(bar lala baz qux),
        StringQuery)
    end

    test "matches quotes" do
      assert CanQL.matches?(
        ~s(foo "bar baz"),
        ~s(foo bar baz qux),
        StringQuery)

      refute CanQL.matches?(
        ~s(foo "bar baz qux" fooo),
        ~s(foo bar baz qux),
        StringQuery)
    end

    test "matches mixed quotes and bools" do
      query = ~s("foo bar" OR "foo baz" AND qux)
      assert CanQL.matches?(query, "foo bar qux", StringQuery)
    end
  end

  describe ".parse/1" do
    test "parses combined boolean and quotes" do
      assert CanQL.parse(~s("foo bar" AND baz)) ==
        [and: {[quote: "foo bar"], [data: "baz"]}]
    end
  end
end
