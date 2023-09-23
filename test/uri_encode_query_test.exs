defmodule UriEncodeQueryTest do
  use ExUnit.Case

  test "keyword list with pairs of atoms" do
    assert UriQuery.params([{:foo, :bar}, {:baz, :quux}]) |> URI.encode_query == "foo=bar&baz=quux"
  end

  test "keyword list with pairs of strings" do
    assert UriQuery.params([{"foo", "bar"}, {"baz", "quux"}]) |> URI.encode_query == "foo=bar&baz=quux"
  end

  test "list value" do
    assert UriQuery.params(foo: ["bar", "quux"]) |> URI.encode_query == "foo%5B0%5D=bar&foo%5B1%5D=quux"
    assert UriQuery.params([foo: ["bar", "quux"]], add_indices_to_lists: false) |> URI.encode_query == "foo%5B%5D=bar&foo%5B%5D=quux"
  end

  test "nested tuple" do
    assert UriQuery.params(foo: {:bar, :baz}) |> URI.encode_query == "foo%5Bbar%5D=baz"
  end

  test "nested tuple list" do
    assert UriQuery.params(foo: [{:bar, :baz}, {:qux, :quux}]) |> URI.encode_query == "foo%5Bbar%5D=baz&foo%5Bqux%5D=quux"
  end

  test "deep nested tuple" do
    assert UriQuery.params(foo: {:bar, {:baz, :quux}}) |> URI.encode_query == "foo%5Bbar%5D%5Bbaz%5D=quux"
  end

  test "simple map" do
    assert UriQuery.params(%{foo: "bar"}) |> URI.encode_query == "foo=bar"
  end

  test "complex cases" do
    assert UriQuery.params([{:foo, [{:bar, ["baz", "quux"]}, {:quux, :corge}]}, {:grault, :garply}]) |> URI.encode_query == "foo%5Bbar%5D%5B0%5D=baz&foo%5Bbar%5D%5B1%5D=quux&foo%5Bquux%5D=corge&grault=garply"
    assert UriQuery.params([{:foo, {:bar, ["baz", "qux"]}}]) |> URI.encode_query == "foo%5Bbar%5D%5B0%5D=baz&foo%5Bbar%5D%5B1%5D=qux"
    assert UriQuery.params([{:foo, [{:bar, ["baz", "quux"]}, {:quux, :corge}]}, {:grault, :garply}], add_indices_to_lists: false) |> URI.encode_query == "foo%5Bbar%5D%5B%5D=baz&foo%5Bbar%5D%5B%5D=quux&foo%5Bquux%5D=corge&grault=garply"
    assert UriQuery.params([{:foo, {:bar, ["baz", "qux"]}}], add_indices_to_lists: false) |> URI.encode_query == "foo%5Bbar%5D%5B%5D=baz&foo%5Bbar%5D%5B%5D=qux"
  end

  def query_contains_all?(actual, expected) do
    actual_parts = String.split(actual, "&")
    expected_parts = String.split(expected, "&")
    Enum.all?(actual_parts, fn part ->
      Enum.member?(expected_parts, part)
    end)
  end

  test "with map" do
    # OTP 26 has changed the order of which maps are iterated, causing order to change
    # when map:to_list/1 is called during Enum.reduce in UriQuery.params/2.
    # So now a order-agnostic test function is used.
    assert query_contains_all?(
      UriQuery.params(%{user: %{name: "Dougal McGuire", email: "test@example.com"}}) |> URI.encode_query,
      "user%5Bemail%5D=test%40example.com&user%5Bname%5D=Dougal+McGuire"
    )
    assert query_contains_all?(
      UriQuery.params(%{user: %{name: "Dougal McGuire", meta: %{foo: "bar", baz: "qux"}}}) |> URI.encode_query,
      "user%5Bmeta%5D%5Bbaz%5D=qux&user%5Bmeta%5D%5Bfoo%5D=bar&user%5Bname%5D=Dougal+McGuire"
    )
    assert query_contains_all?(
      UriQuery.params(%{user: %{name: "Dougal McGuire", meta: %{test: "Example", data: ["foo", "bar"]}}}) |> URI.encode_query,
      "user%5Bmeta%5D%5Bdata%5D%5B0%5D=foo&user%5Bmeta%5D%5Bdata%5D%5B1%5D=bar&user%5Bmeta%5D%5Btest%5D=Example&user%5Bname%5D=Dougal+McGuire"
    )
    assert query_contains_all?(
      UriQuery.params(%{user: %{name: "Dougal McGuire", meta: %{test: "Example", data: ["foo", "bar"]}}}, add_indices_to_lists: false) |> URI.encode_query,
      "user%5Bmeta%5D%5Bdata%5D%5B%5D=foo&user%5Bmeta%5D%5Bdata%5D%5B%5D=bar&user%5Bmeta%5D%5Btest%5D=Example&user%5Bname%5D=Dougal+McGuire"
    )
  end

  test "ignores empty list" do
    assert UriQuery.params(foo: []) |> URI.encode_query == ""
    assert UriQuery.params(foo: [], bar: "quux") |> URI.encode_query == "bar=quux"
    assert UriQuery.params(foo: [], bar: ["quux", []]) |> URI.encode_query == "bar%5B0%5D=quux"
    assert UriQuery.params([foo: [], bar: ["quux", []]], add_indices_to_lists: false) |> URI.encode_query == "bar%5B%5D=quux"
  end
end
