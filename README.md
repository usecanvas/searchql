# SearchQL [![CircleCI](https://circleci.com/gh/usecanvas/searchql.svg?style=svg)](https://circleci.com/gh/usecanvas/searchql)

SearchQL is a search query parser written in Elixir. Given a query such as:

```
foo AND bar OR "qux AND quux" OR corge AND grault AND garply
```

SearchQL can generate a data representation of the query:

```elixir
[or: {
  [or: {
    [and: {[data: "foo"], [data: "bar"]}],
    [quote: "qux AND quux"]}],
  [and: {
    [and: {[data: "corge"], [data: "grault"]}],
    [data: "garply"]}]}]
```

Notice that in the query parsing, `AND` binds tighter than `OR`, and both
operators are left-associative. This seems to give the best interpretation of
what a human would mean when typing such a query.

A programmer can use SearchQL to determine whether a search query matches a
piece of data by providing a module such as
[SearchQL.StringQuerier][string_querier] that implements the
[SearchQL.Querier behaviour][querier_behaviour]:

```elixir
SearchQL.matches?(
  ~s(foo and bar or baz),
  ~s(baz),
  SearchQL.StringQuerier) # true
```

For more info, see the [SearchQL documentation][searchql_documentation].

## Installation

  1. Add `searchql` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:searchql, "~> 1.0.0"}]
    end
    ```

  2. Ensure `searchql` is started before your application:

    ```elixir
    def application do
      [applications: [:searchql]]
    end
    ```

[querier_behaviour]: https://github.com/usecanvas/searchql/blob/master/lib/searchql/querier.ex
[searchql_documentation]: https://hexdocs.pm/searchql/readme.html
[string_querier]: https://github.com/usecanvas/searchql/blob/master/test/support/string_querier.ex
