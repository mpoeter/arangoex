defmodule Arango.Document do
  @moduledoc "ArangoDB Document methods"

  alias Arango.Request
  alias Arango.Collection
  alias Arango.Document
  alias Arango.Utils

  defmodule Docref do
    @moduledoc false

    defstruct [:_key, :_id, :_rev, :_oldRev]
    use ExConstructor
  end

  defimpl Jason.Encoder, for: Docref do
    def encode(value, opts) do
      value |> Map.from_struct() |> Jason.Encode.map(opts)
    end
  end

  @type t :: %__MODULE__.Docref{
    _key: String.t,
    _id: String.t,
    _rev: nil | String.t,
    _oldRev: nil | String.t,
  }

  @doc """
  Create document

  POST /_api/document/{collection}
  """
  @spec create(Collection.t, map() | [map()], Keyword.t) :: Request.t
  def create(collection, document, opts \\ []) do
    query = Utils.opts_to_query(opts, [:waitForSync, :returnNew])

    %Request{
      endpoint: :document,
      http_method: :post,
      path: "document/#{collection.name}",
      query: query,
      body: document,
      ok_decoder: __MODULE__.DocumentDecoder,
    }
  end

  @doc """
  Read document header

  HEAD /_api/document/{document-handle}
  """
  @spec header(map(), Keyword.t) :: Request.t
  def header(document, opts \\ []) do
    headers = Utils.opts_to_headers(opts, [:ifNoneMatch, :ifMatch])

    %Request{
      endpoint: :document,
      http_method: :head,
      path: "document/#{document._id}",
      headers: headers,
    }
  end

  @doc """
  Read document

  GET /_api/document/{document-handle}
  """
  @spec document(Document.t, Keyword.t) :: Request.t
  def document(document, opts \\ []) do
    headers = Utils.opts_to_headers(opts, [:ifNoneMatch, :ifMatch])

    %Request{
      endpoint: :document,
      http_method: :get,
      path: "document/#{document._id}",
      headers: headers,
    }
  end

  @doc """
  Read all documents

  PUT /_api/simple/all-keys
  """
  @spec documents(Collection.t, Keyword.t) :: Request.t
  def documents(collection, opts \\ []) do
    type = Utils.ensure_permitted(opts, [:type])[:type]
    body = cond do
      type == :id   -> %{"collection" => collection.name, "type" => "id"}
      type == :path -> %{"collection" => collection.name, "type" => "path"}
      type == :key  -> %{"collection" => collection.name, "type" => "key"}
      type == nil   -> %{"collection" => collection.name}
      true -> raise "unknown type: #{type}"
    end

    %Request{
      endpoint: :document,
      http_method: :put,
      path: "simple/all-keys",
      body: body,
    }
  end

  def update(collection, docs, opts \\ [])

  @doc """
  Update documents

  PATCH /_api/document/{collection}
  """
  @spec update(Collection.t, [map()], Keyword.t) :: Request.t
  def update(%Collection{} = collection, new_docs, opts) when is_list(new_docs) do
    query = Utils.opts_to_query(opts, [:keepNull, :mergeObjects, :waitForSync, :ignoreRevs, :returnOld, :returnNew])

    %Request{
      endpoint: :document,
      http_method: :patch,
      path: "document/#{collection.name}",
      query: query,
      body: new_docs,
      ok_decoder: __MODULE__.DocumentDecoder,
    }
  end

  @doc """
  Update document

  PATCH /_api/document/{document-handle}
  """
  @spec update(map(), map(), Keyword.t) :: Request.t
  def update(document, new_document, opts) do
    {header_opts, query_opts} = Keyword.split(opts, [:ifMatch])
    headers = Utils.opts_to_headers(header_opts, [:ifMatch])
    query = Utils.opts_to_query(query_opts, [:keepNull, :mergeObjects, :waitForSync, :ignoreRevs, :returnOld, :returnNew])

    %Request{
      endpoint: :document,
      http_method: :patch,
      path: "document/#{document._id}",
      query: query,
      headers: headers,
      body: new_document,
      ok_decoder: __MODULE__.DocumentDecoder,
    }
  end

  def replace(collection, docs, opts \\ [])

  @doc """
  Replace documents

  PUT /_api/document/{collection}
  """
  @spec replace(Collection.t, [map()], Keyword.t) :: Request.t
  def replace(%Collection{} = collection, new_docs, opts) when is_list(new_docs) do
    query = Utils.opts_to_query(opts, [:keepNull, :mergeObjects, :waitForSync, :ignoreRevs, :returnOld, :returnNew])

    %Request{
      endpoint: :document,
      http_method: :put,
      path: "document/#{collection.name}",
      query: query,
      body: new_docs,
      ok_decoder: __MODULE__.DocumentDecoder,
    }
  end

  @doc """
  Replace document

  PUT /_api/document/{document-handle}
  """
  @spec replace(Document.t, map(), Keyword.t) :: Request.t
  def replace(document, new_document, opts) do
    {header_opts, query_opts} = Keyword.split(opts, [:ifMatch])
    headers = Utils.opts_to_headers(header_opts, [:ifMatch])
    query = Utils.opts_to_query(query_opts, [:keepNull, :mergeObjects, :waitForSync, :ignoreRevs, :returnOld, :returnNew])

    %Request{
      endpoint: :document,
      http_method: :put,
      path: "document/#{document._id}",
      query: query,
      body: new_document,
      headers: headers,
      ok_decoder: __MODULE__.DocumentDecoder,
    }
  end

  @doc """
  Removes multiple documents

  DELETE /_api/document/{collection}
  """
  @spec delete_multi(Collection.t, [map()], Keyword.t) :: Request.t
  def delete_multi(collection, docs, opts \\ []) when is_list(docs) do
    query = Utils.opts_to_query(opts, [:waitForSync, :ignoreRevs, :returnOld])

    %Request{
      endpoint: :document,
      http_method: :delete,
      path: "document/#{collection.name}",
      query: query,
      body: docs,
      ok_decoder: __MODULE__.DocumentDecoder,
    }
  end

  @doc """
  Removes a document

  DELETE /_api/document/{document-handle}
  """
  @spec delete(Document.t, Keyword.t) :: Request.t
  def delete(document, opts \\ []) do
    {header_opts, query_opts} = Keyword.split(opts, [:ifMatch])
    headers = Utils.opts_to_headers(header_opts, [:ifMatch])
    query = Utils.opts_to_query(query_opts, [:waitForSync, :returnOld])

    %Request{
      endpoint: :document,
      http_method: :delete,
      path: "document/#{document._id}",
      query: query,
      headers: headers,
      ok_decoder: __MODULE__.DocumentDecoder,
    }
  end

  defmodule DocumentDecoder do
    @spec decode_ok(map() | [map()]) :: Arango.ok_error(any())
    def decode_ok(result) when is_list(result), do: Enum.map(result, &to_document(&1))
    def decode_ok(result), do: to_document(result)

    defp to_document(%{} = result) do
      case result do
        %{"error" => true, "errorMessage" => _em, "errorNum" => _en} -> {:error, result}
        %{"old" => old, "new" => new} -> {:ok, {Docref.new(result), old, new}}
        %{"old" => old} -> {:ok, {Docref.new(result), old}}
        %{"new" => new} -> {:ok, {Docref.new(result), new}}
        %{"_id" => _id} -> {:ok, Docref.new(result)}
      end
    end
  end
end
