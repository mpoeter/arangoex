defmodule Arango.Utils do
  @moduledoc false

  @spec opts_to_headers(Keyword.t, [atom()]) :: map()
  def opts_to_headers(opts, permitted \\ []) do
    opts
    |> ensure_permitted(permitted)
    |> Enum.map(fn {k, v} -> {to_header_name(k), v} end)
    |> Enum.into(%{})
  end

  @spec opts_to_query(Keyword.t, [atom()]) :: map()
  def opts_to_query(opts, permitted \\ []) do
    opts_to_vars(opts, permitted)
  end

  @spec opts_to_vars(Keyword.t, [atom()]) :: map()
  def opts_to_vars(opts, permitted \\ []) do
    opts
    |> ensure_permitted(permitted)
    |> Enum.map(fn {k, v} -> {"#{k}", v} end)
    |> Enum.into(%{})
  end

  @doc """
  Filters keywords for permitted attributes given as a keyword list in
  permitted. If a single atom of :* is passed in, all attributes are
  returned. Permitted defaults to an empty keyword list.
  """
  @spec ensure_permitted(Keyword.t, [atom()]) :: Keyword.t
  def ensure_permitted(opts, [:*]), do: opts
  def ensure_permitted(opts, permitted) do
    extra = Keyword.keys(opts) -- permitted
    Enum.any?(extra, &(raise "unknown key: #{&1}"))
    opts
    |> Enum.reject(fn {_, v} -> v == nil end)
    |> Keyword.take(permitted)
  end

  @spec to_header_name(atom() | String.t) :: String.t
  def to_header_name(a) when is_atom(a), do: to_header_name(Atom.to_string(a))
  def to_header_name(a) do
    a
    |> Macro.underscore
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("-")
  end
end
