defmodule CanQLTest do
  use ExUnit.Case

  doctest CanQL

  alias CanQL.StringQuerier

  describe ".matches?/2" do
    test "matches basic string" do
      assert CanQL.matches?(~s(foo bar), "foo bar baz", StringQuerier)
      refute CanQL.matches?(~s(foo bar), "foo baz baz", StringQuerier)
    end

    test "matches basic OR" do
      assert CanQL.matches?(~s(foo OR bar), "foo", StringQuerier)
      assert CanQL.matches?(~s(foo OR bar), "bar", StringQuerier)
      refute CanQL.matches?(~s(foo OR bar), "baz", StringQuerier)
    end

    test "matches multiple OR" do
      assert CanQL.matches?(~s(foo OR bar OR baz), "foo", StringQuerier)
      assert CanQL.matches?(~s(foo OR bar OR baz), "bar", StringQuerier)
      refute CanQL.matches?(~s(foo OR bar OR baz), "qux", StringQuerier)
    end

    test "matches basic AND" do
      assert CanQL.matches?(~s(foo AND bar), "foo bar", StringQuerier)
      refute CanQL.matches?(~s(foo AND bar), "foo baz", StringQuerier)
    end

    test "matches multiple AND" do
      assert CanQL.matches?(~s(foo AND bar AND baz), "foo bar baz", StringQuerier)
      refute CanQL.matches?(~s(foo AND bar AND baz), "foo bar qux", StringQuerier)
    end

    test "matches combination AND and OR" do
      assert CanQL.matches?(
        ~s(foo OR bar AND baz AND qux OR foo2 OR bar2),
        ~s(bar lala baz qux),
        StringQuerier)
    end

    test "matches quotes" do
      assert CanQL.matches?(
        ~s(foo "bar baz"),
        ~s(foo bar baz qux),
        StringQuerier)

      refute CanQL.matches?(
        ~s(foo "bar baz qux" fooo),
        ~s(foo bar baz qux),
        StringQuerier)
    end

    test "matches mixed quotes and bools" do
      query = ~s("foo bar" OR "foo baz" AND qux)
      assert CanQL.matches?(query, "foo bar qux", StringQuerier)
    end
  end

  describe ".parse/1" do
    test "parses combined boolean and quotes" do
      assert CanQL.parse(~s("foo bar" AND baz)) ==
        [and: {[quote: "foo bar"], [data: "baz"]}]
    end
  end
end
