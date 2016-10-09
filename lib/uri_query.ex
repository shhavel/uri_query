defmodule UriQuery do
  @doc """
  For cases when lists and maps are used in GET parameters.

  Returns keyword list corresponding to given enumerable
  that is safe to be encoded into a query string.

  Keys and Values can be any term that implements the `String.Chars`
  protocol. Lists connot be used as keys.
  Values can be lists or maps including nested maps.

  ## Examples

  iex> query = %{"foo" => 1, "bar" => 2}
  iex> UriQuery.params(query)
  [{"bar", "2"}, {"foo", "1"}]

  iex> query = %{foo: ["bar", "baz"]}
  iex> UriQuery.params(query)
  [{"foo[]", "bar"}, {"foo[]", "baz"}]

  iex> query = %{"user" => %{"name" => "John Doe", "email" => "test@example.com"}}
  iex> UriQuery.params(query)
  [{"user[email]", "test@example.com"}, {"user[name]", "John Doe"}]

  """

  @noKVListError "parameter for params/1 must be a list of key-value pairs"

  def params(enumerable) do
    if(is_enumerable(enumerable)) do
      enumerable
      |> Enum.reduce([], fn(pair, acc) -> accumulate_kv_pair("", pair, false, acc) end)
      |> Enum.reverse  
    else
      raise ArgumentError, @noKVListError
    end
  end 

  defp is_enumerable(value) do
    is_list(value) or is_map(value)
  end

  defp accumulate_kv_pair(_, {key, _}, _, _) when is_list(key), do: raise ArgumentError, "params/1 keys cannot be lists, got: #{inspect key}"
  defp accumulate_kv_pair(prefix, {key, values}, false, acc) when is_list(values) or is_map(values) do
    Enum.reduce(values, acc, fn (value, acc) -> accumulate_kv_pair(prefix, {key, value}, true, acc) end)
  end
  defp accumulate_kv_pair(prefix, {key, {nested_key, value}}, _, acc) do
    key
    |> build_key(prefix)
    |> accumulate_kv_pair({build_nested_key(nested_key), value}, false, acc)
  end
  defp accumulate_kv_pair(prefix, {key, value}, true, acc) , do: [{build_key(key, prefix, "[]"), to_string(value)} | acc]
  defp accumulate_kv_pair(prefix, {key, value}, false, acc), do: [{build_key(key, prefix), to_string(value)} | acc]
  defp accumulate_kv_pair(_, pair, _, _), do: raise ArgumentError, @noKVListError
  
  defp build_key(key, prefix)        , do: build_key(key, prefix, "")
  defp build_key(key, prefix, suffix), do: prefix <> to_string(key) <> suffix

  defp build_nested_key(nested_key), do: "[#{to_string(nested_key)}]"
end
