defmodule CanqlTest do
  use ExUnit.Case

  doctest CanQL

  test "parses basic string" do
    assert CanQL.parse(~s(foo bar)) == {:query, [has: ["foo bar"]]}
  end

  test "parses basic AND" do
    assert CanQL.parse(~s(foo AND bar baz)) ==
      {:query, [
        and: [
          has: ["foo"], has: ["bar baz"]]]}
  end

  test "parses multiple AND" do
    assert CanQL.parse(~s(foo AND bar AND baz)) ==
      {:query, [
        and: [
          and: [
            has: ["foo"], has: ["bar"]],
          has: ["baz"]]]}
  end

  test "parses basic OR" do
    assert CanQL.parse(~s(foo OR bar)) ==
      {:query, [
        or: [
          has: ["foo"], has: ["bar"]]]}
  end

  test "parses multiple OR" do
    assert CanQL.parse(~s(foo OR bar OR baz)) ==
      {:query, [
        or: [
          or: [
            has: ["foo"], has: ["bar"]],
          has: ["baz"]]]}
  end

  test "parses combination AND and OR" do
    assert CanQL.parse(~s(foo OR bar AND baz AND qux OR foo2 OR bar2)) ==
      {:query, [
        and: [
          and: [
            or: [
              has: ["foo"], has: ["bar"]],
            has: ["baz"]],
          or: [
            or: [
              has: ["qux"], has: ["foo2"]],
            has: ["bar2"]]]]}
  end
end
