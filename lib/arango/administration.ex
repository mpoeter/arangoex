defmodule Arango.Administration do
  @moduledoc "ArangoDB Administration methods"

  alias Arango.Request
  alias Arango.Utils

  @doc """
  Return the required version of the database

  GET /_admin/database/target-version
  """
  @spec database_version() :: Request.t
  def database_version() do
    %Request{
      endpoint: :administration,
      http_method: :get,
      path: "/_admin/database/target-version"
    }
  end

  @doc """
  Return current request

  GET /_admin/echo
  """
  @spec echo(Keyword.t, Keyword.t) :: Request.t
  def echo(query_opts \\ [], header_opts \\ []) do
    headers = Utils.opts_to_headers(header_opts, [:*])
    query = Utils.opts_to_query(query_opts, [:*])

    %Request{
      endpoint: :administration,
      http_method: :get,
      headers: headers,
      path: "/_admin/echo",
      query: query
    }
  end

  @doc """
  Execute program

  POST /_admin/execute
  """
  @spec execute(String.t, Keyword.t) :: Request.t
  def execute(code, opts \\ []) do
    query = Utils.opts_to_query(opts, [:returnAsJson])

    %Request{
      endpoint: :administration,
      http_method: :post,
      body: code,
      path: "/_admin/execute",
      query: query,
      encode_body: false
    }
  end

  @doc """
  Read global logs from the server

  GET /_admin/log
  """
  @spec log() :: Request.t
  def log(opts \\ []) do
    query = Utils.opts_to_query(opts, [:upto, :level, :start, :size, :offset, :search, :sort])

    %Request{
      endpoint: :administration,
      http_method: :get,
      path: "/_admin/log",
      query: query,
    }
  end

  @doc """
  Return current request and continues

  GET /_admin/long_echo
  """
  @spec long_echo() :: Request.t
  def long_echo(query_opts \\ [], header_opts \\ []) do
    headers = Utils.opts_to_headers(header_opts, [:*])
    query = Utils.opts_to_query(query_opts, [:*])

    %Request{
      endpoint: :administration,
      http_method: :get,
      headers: headers,
      path: "/_admin/long_echo",
      query: query,
    }
  end

  @doc """
  Reloads the routing information

  POST /_admin/routing/reload
  """
  @spec reload_routing() :: Request.t
  def reload_routing() do
    %Request{
      endpoint: :administration,
      http_method: :post,
      path: "/_admin/routing/reload"
    }
  end

  @doc """
  Return id of a server in a cluster

  GET /_admin/server/id
  """
  @spec server_id() :: Request.t
  def server_id() do
    %Request{
      endpoint: :administration,
      http_method: :get,
      path: "/_admin/server/id"
    }
  end

  @doc """
  Return role of a server in a cluster

  GET /_admin/server/role
  """
  @spec server_role() :: Request.t
  def server_role() do
    %Request{
      endpoint: :administration,
      http_method: :get,
      path: "/_admin/server/role"
    }
  end

  @doc """
  Initiate shutdown sequence

  DELETE /_admin/shutdown
  """
  @spec shutdown() :: Request.t
  def shutdown() do
    %Request{
      endpoint: :administration,
      http_method: :delete,
      path: "/_admin/shutdown"
    }
  end

  @doc """
  Sleep for a specified amount of seconds

  GET /_admin/sleep
  """
  @spec sleep(Keyword.t) :: Request.t
  def sleep(opts \\ []) do
    query = Utils.opts_to_query(opts, [:duration])

    %Request{
      endpoint: :administration,
      http_method: :get,
      path: "/_admin/sleep",
      query: query,
    }
  end

  @doc """
  Read the statistics

  GET /_admin/statistics
  """
  @spec statistics() :: Request.t
  def statistics() do
    %Request{
      endpoint: :administration,
      http_method: :get,
      path: "/_admin/statistics"
    }
  end

  @doc """
  Statistics description

  GET /_admin/statistics-description
  """
  @spec statistics_description() :: Request.t
  def statistics_description() do
    %Request{
      endpoint: :administration,
      http_method: :get,
      path: "/_admin/statistics-description"
    }
  end

  @doc """
  Runs tests on server

  POST /_admin/test
  """
  @spec test() :: Request.t
  def test() do
    %Request{
      endpoint: :administration,
      http_method: :post,
      path: "/_admin/test"
    }
  end

  @doc """
  Return system time

  GET /_admin/time
  """
  @spec time() :: Request.t
  def time() do
    %Request{
      endpoint: :administration,
      http_method: :get,
      path: "/_admin/time"
    }
  end

  @doc """
  Return list of all endpoints

  GET /_api/endpoint
  """
  @spec endpoints() :: Request.t
  def endpoints() do
    %Request{
      endpoint: :administration,
      system_only: true,           # or just /_api? Same thing?
      http_method: :get,
      path: "endpoint"
    }
  end

  @doc """
  Return server version

  GET /_api/version
  """
  @spec version() :: Request.t
  def version() do
    %Request{
      endpoint: :administration,
      system_only: true,           # or just /_api? Same thing?
      http_method: :get,
      path: "version"
    }
  end
end
