# UriQuery [![Build Status](https://travis-ci.org/shhavel/uri_query.svg?branch=master)](https://travis-ci.org/shhavel/uri_query)

URI encode nested GET parameters and array values.

Prepares URI query parameters to be used in `URI.encode_query/1` or `HTTPoison.get/3`

https://hexdocs.pm/uri_query/0.1.1/UriQuery.html

## Installation

The package can be installed as:

1. Add `uri_query` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:uri_query, "~> 0.1.1"}]
end
```

2. Ensure `uri_query` is started before your application:

```elixir
def application do
  [applications: [:uri_query]]
end
```

## Usage

With list values

```elixir
iex> UriQuery.params(foo: ["bar", "quux"]) |> URI.encode_query
"foo%5B0%5D=bar&foo%5B1%5D=quux"

iex> UriQuery.params([foo: ["bar", "quux"]], add_indices_to_lists: false) |> URI.encode_query
"foo%5B%5D=bar&foo%5B%5D=quux"

iex> HTTPoison.get("http://example.com", [], params: UriQuery.params(foo: ["bar", "quux"]))
```

With nested structures (maps or keyword lists)

```elixir
iex> UriQuery.params(%{user: %{name: "Dougal McGuire", email: "test@example.com"}}) |> URI.encode_query
"user%5Bemail%5D=test%40example.com&user%5Bname%5D=Dougal+McGuire"

iex> params = %{user: %{name: "Dougal McGuire", email: "test@example.com"}} |> UriQuery.params
[{"user[email]", "test@example.com"}, {"user[name]", "Dougal McGuire"}]
iex> HTTPoison.get("http://example.com", [], params: params)
```

NOTE: Empty lists are ignored

```elixir
iex> UriQuery.params(foo: []) |> URI.encode_query
""
```
