defmodule Arango.Wal do
  @moduledoc "ArangoDB Wal methods"

  alias Arango.Request
  alias Arango.Utils

  defstruct [
    :allowOversizeEntries,
    :logfileSize,
    :historicLogfiles,
    :reserveLogfiles,
    :syncInterval,
    :throttleWait,
    :throttleWhenPending,
  ]
  use ExConstructor

  @type t :: %__MODULE__{
    allowOversizeEntries: boolean,
    logfileSize: pos_integer,
    historicLogfiles: non_neg_integer,
    reserveLogfiles: non_neg_integer,
    syncInterval: pos_integer,
    throttleWait: pos_integer,
    throttleWhenPending: non_neg_integer,
  }

  @doc """
  Flushes the write-ahead log

  PUT /_admin/wal/flush
  """
  @spec flush(Keyword.t) :: Request.t
  def flush(opts \\ []) do
    flush_opts = Utils.opts_to_vars(opts, [:waitForSync, :waitForCollector])

    %Request{
      endpoint: :wal,
      system_only: true,   # or just /_api? Same thing?
      http_method: :put,
      path: "/_admin/wal/flush",
      body: flush_opts,
    }
  end

  @doc """
  Retrieves the configuration of the write-ahead log

  GET /_admin/wal/properties
  """
  @spec properties() :: Request.t
  def properties() do
    %Request{
      endpoint: :wal,
      system_only: true,   # or just /_api? Same thing?
      http_method: :get,
      path: "/_admin/wal/properties",
      ok_decoder: __MODULE__.WalDecoder,
    }
  end

  @doc """
  Configures the write-ahead log

  PUT /_admin/wal/properties
  """
  @spec set_properties(t | Keyword.t) :: Request.t
  def set_properties(%__MODULE__{} = properties), do: set_properties(properties |> Map.from_struct |> Enum.into([]))
  def set_properties(properties) do
    defaults = %__MODULE__{} |> Map.from_struct |> Map.keys
    wal_properties = Utils.opts_to_vars(properties, defaults)

    %Request{
      endpoint: :wal,
      system_only: true,   # or just /_api? Same thing?
      http_method: :put,
      path: "/_admin/wal/properties",
      body: wal_properties,
      ok_decoder: __MODULE__.WalDecoder,
    }
  end

  @doc """
  Returns information about the currently running transactions

  GET /_admin/wal/transactions
  """
  @spec transactions() :: Request.t
  def transactions() do
    %Request{
      endpoint: :wal,
      system_only: true,   # or just /_api? Same thing?
      http_method: :get,
      path: "/_admin/wal/transactions",
    }
  end

  defmodule WalDecoder do
    alias Arango.Wal

    @spec decode_ok(map()) :: Arango.ok_error(Wal.t)
    def decode_ok(result), do: {:ok, Wal.new(result)}
  end
end
