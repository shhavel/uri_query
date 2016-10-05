defmodule UriQueryTest do
  use ExUnit.Case
  doctest UriQuery

  test "list cannot be used as a key" do
    assert_raise ArgumentError, "params/1 keys cannot be lists, got: 'foo'", fn ->
      UriQuery.params([{'foo', "bar"}])
    end
  end

  test "keyword list with pairs of atoms" do
    assert UriQuery.params([{:foo, :bar}, {:baz, :quux}]) == [{"foo", "bar"}, {"baz", "quux"}]
  end

  test "keyword list with pairs of strings" do
    assert UriQuery.params([{"foo", "bar"}, {"baz", "quux"}]) == [{"foo", "bar"}, {"baz", "quux"}]
  end

  test "list value" do
    assert UriQuery.params(foo: ["bar", "quux"]) == [{"foo[]", "bar"}, {"foo[]", "quux"}]
  end

  test "nested tupple" do
    assert UriQuery.params(foo: {:bar, :baz}) == [{"foo[bar]", "baz"}]
  end

  test "nested tupple list" do
    assert UriQuery.params(foo: [{:bar, :baz}, {:qux, :quux}]) == [{"foo[bar]", "baz"}, {"foo[qux]", "quux"}]
  end

  test "deep nested tupple" do
    assert UriQuery.params(foo: {:bar, {:baz, :quux}}) == [{"foo[bar][baz]", "quux"}]
  end

  test "complex cases" do
    assert UriQuery.params([{:foo, [{:bar, ["baz", "quux"]}, {:quux, :corge}]}, {:grault, :garply}]) == [{"foo[bar][]", "baz"}, {"foo[bar][]", "quux"}, {"foo[quux]", "corge"}, {"grault", "garply"}]
    assert UriQuery.params([{:foo, {:bar, ["baz", "qux"]}}]) == [{"foo[bar][]", "baz"}, {"foo[bar][]", "qux"}]
  end

  test "with map" do
    assert UriQuery.params(%{user: %{name: "Dougal McGuire", email: "test@example.com"}}) == [{"user[email]", "test@example.com"}, {"user[name]", "Dougal McGuire"}]
    assert UriQuery.params(%{user: %{name: "Dougal McGuire", meta: %{foo: "bar", baz: "qux"}}}) == [{"user[meta][baz]", "qux"}, {"user[meta][foo]", "bar"}, {"user[name]", "Dougal McGuire"}]
    assert UriQuery.params(%{user: %{name: "Dougal McGuire", meta: %{test: "Example", data: ["foo", "bar"]}}}) == [{"user[meta][data][]", "foo"}, {"user[meta][data][]", "bar"}, {"user[meta][test]", "Example"}, {"user[name]", "Dougal McGuire"}]
  end
end
