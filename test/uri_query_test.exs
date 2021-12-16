defmodule UriQueryTest do
  use ExUnit.Case
  doctest UriQuery

  test "no list" do
    assert_raise ArgumentError, "parameter for params/1 must be a list of key-value pairs", fn ->
      UriQuery.params("foo")
    end
  end

  test "no key-value pair" do
    assert_raise ArgumentError, "parameter for params/1 must be a list of key-value pairs", fn ->
      UriQuery.params([:foo, :bar])
    end
  end

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
    assert UriQuery.params(foo: ["bar", "quux"]) == [{"foo[0]", "bar"}, {"foo[1]", "quux"}]
    assert UriQuery.params([foo: ["bar", "quux"]], add_indices_to_lists: false) == [{"foo[]", "bar"}, {"foo[]", "quux"}]
  end

  test "nested tuple" do
    assert UriQuery.params(foo: {:bar, :baz}) == [{"foo[bar]", "baz"}]
  end

  test "nested tuple list" do
    assert UriQuery.params(foo: [{:bar, :baz}, {:qux, :quux}]) == [{"foo[bar]", "baz"}, {"foo[qux]", "quux"}]
  end

  test "deep nested tuple" do
    assert UriQuery.params(foo: {:bar, {:baz, :quux}}) == [{"foo[bar][baz]", "quux"}]
  end

  test "simple map" do
    assert UriQuery.params(%{foo: "bar"}) == [{"foo", "bar"}]
  end

  test "complex cases" do
    assert UriQuery.params([{:foo, [{:bar, ["baz", "quux"]}, {:quux, :corge}]}, {:grault, :garply}]) == [{"foo[bar][0]", "baz"}, {"foo[bar][1]", "quux"}, {"foo[quux]", "corge"}, {"grault", "garply"}]
    assert UriQuery.params([{:foo, {:bar, ["baz", "qux"]}}]) == [{"foo[bar][0]", "baz"}, {"foo[bar][1]", "qux"}]
    assert UriQuery.params([{:foo, [{:bar, ["baz", "quux"]}, {:quux, :corge}]}, {:grault, :garply}], add_indices_to_lists: false) == [{"foo[bar][]", "baz"}, {"foo[bar][]", "quux"}, {"foo[quux]", "corge"}, {"grault", "garply"}]
    assert UriQuery.params([{:foo, {:bar, ["baz", "qux"]}}], add_indices_to_lists: false) == [{"foo[bar][]", "baz"}, {"foo[bar][]", "qux"}]
  end

  test "with map" do
    assert UriQuery.params(%{user: %{name: "Dougal McGuire", email: "test@example.com"}}) == [{"user[email]", "test@example.com"}, {"user[name]", "Dougal McGuire"}]
    assert UriQuery.params(%{user: %{name: "Dougal McGuire", meta: %{foo: "bar", baz: "qux"}}}) == [{"user[meta][baz]", "qux"}, {"user[meta][foo]", "bar"}, {"user[name]", "Dougal McGuire"}]
    assert UriQuery.params(%{user: %{name: "Dougal McGuire", meta: %{test: "Example", data: ["foo", "bar"]}}}) == [{"user[meta][data][0]", "foo"}, {"user[meta][data][1]", "bar"}, {"user[meta][test]", "Example"}, {"user[name]", "Dougal McGuire"}]
    assert UriQuery.params(%{user: %{name: "Dougal McGuire", meta: %{test: "Example", data: ["foo", "bar"]}}}, add_indices_to_lists: false) == [{"user[meta][data][]", "foo"}, {"user[meta][data][]", "bar"}, {"user[meta][test]", "Example"}, {"user[name]", "Dougal McGuire"}]
  end

  test "ignores empty list" do
    assert UriQuery.params(foo: []) == []
    assert UriQuery.params(foo: [], bar: "quux") == [{"bar", "quux"}]
    assert UriQuery.params(foo: [], bar: ["quux", []]) == [{"bar[0]", "quux"}]
    assert UriQuery.params([foo: [], bar: ["quux", []]], add_indices_to_lists: false) == [{"bar[]", "quux"}]
  end
end
