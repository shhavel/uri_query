defmodule UriEncodeQueryTest do
  use ExUnit.Case

  test "keyword list with pairs of atoms" do
    assert UriQuery.params([{:foo, :bar}, {:baz, :quux}]) |> URI.encode_query == "foo=bar&baz=quux"
  end

  test "keyword list with pairs of strings" do
    assert UriQuery.params([{"foo", "bar"}, {"baz", "quux"}]) |> URI.encode_query == "foo=bar&baz=quux"
  end

  test "list value" do
    assert UriQuery.params(foo: ["bar", "quux"]) |> URI.encode_query == "foo%5B%5D=bar&foo%5B%5D=quux"
  end

  test "nested tupple" do
    assert UriQuery.params(foo: {:bar, :baz}) |> URI.encode_query == "foo%5Bbar%5D=baz"
  end

  test "nested tupple list" do
    assert UriQuery.params(foo: [{:bar, :baz}, {:qux, :quux}]) |> URI.encode_query == "foo%5Bbar%5D=baz&foo%5Bqux%5D=quux"
  end

  test "deep nested tupple" do
    assert UriQuery.params(foo: {:bar, {:baz, :quux}}) |> URI.encode_query == "foo%5Bbar%5D%5Bbaz%5D=quux"
  end

  test "simple map" do
    assert UriQuery.params(%{foo: "bar"}) |> URI.encode_query == "foo=bar"
  end

  test "complex cases" do
    assert UriQuery.params([{:foo, [{:bar, ["baz", "quux"]}, {:quux, :corge}]}, {:grault, :garply}]) |> URI.encode_query == "foo%5Bbar%5D%5B%5D=baz&foo%5Bbar%5D%5B%5D=quux&foo%5Bquux%5D=corge&grault=garply"
    assert UriQuery.params([{:foo, {:bar, ["baz", "qux"]}}]) |> URI.encode_query == "foo%5Bbar%5D%5B%5D=baz&foo%5Bbar%5D%5B%5D=qux"
  end

  test "with map" do
    assert UriQuery.params(%{user: %{name: "Dougal McGuire", email: "test@example.com"}}) |> URI.encode_query == "user%5Bemail%5D=test%40example.com&user%5Bname%5D=Dougal+McGuire"
    assert UriQuery.params(%{user: %{name: "Dougal McGuire", meta: %{foo: "bar", baz: "qux"}}}) |> URI.encode_query == "user%5Bmeta%5D%5Bbaz%5D=qux&user%5Bmeta%5D%5Bfoo%5D=bar&user%5Bname%5D=Dougal+McGuire"
    assert UriQuery.params(%{user: %{name: "Dougal McGuire", meta: %{test: "Example", data: ["foo", "bar"]}}}) |> URI.encode_query == "user%5Bmeta%5D%5Bdata%5D%5B%5D=foo&user%5Bmeta%5D%5Bdata%5D%5B%5D=bar&user%5Bmeta%5D%5Btest%5D=Example&user%5Bname%5D=Dougal+McGuire"
  end
end


