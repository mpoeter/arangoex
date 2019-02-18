defmodule Arango.User do
  @moduledoc "ArangoDB User methods"

  alias Arango.Database
  alias Arango.Request
  alias Arango.Utils

  defstruct [
    user: nil,
    active: nil,
    extra: nil,
    changePassword: nil,
    passwd: nil,
  ]
  use ExConstructor

  @type t :: %__MODULE__{
    user: String.t,
    active: boolean,
    extra: map(),
    changePassword: boolean,
    passwd: String.t,
  }

  @doc """
  Create User

  POST /_api/user
  """
  @type create_user_opts :: [{:user, String.t} | {:passwd, String.t} | {:active, boolean} | {:extra, map()}]
  @spec create(create_user_opts | t) :: Request.t
  def create(user \\ [])
  def create(%__MODULE__{user: name}), do: create(user: name)
  def create(opts) do
    %Request{
      endpoint: :user,
      system_only: true,   # or just /_api? Same thing?
      http_method: :post,
      path: "user",
      body: opts |> Keyword.take([:user, :passwd, :active, :extra]) |> Enum.into(%{}),
      ok_decoder: __MODULE__.UserDecoder,
    }
  end

  @doc """
  Remove User

  DELETE /_api/user/{user}
  """
  @spec remove(t | String.t) :: Request.t
  def remove(%__MODULE__{user: name}), do: remove(name)
  def remove(name) do
    %Request{
      endpoint: :user,
      system_only: true,   # or just /_api? Same thing?
      http_method: :delete,
      path: "user/#{name}",
    }
  end

  @doc """
  List available Users

  GET /_api/user/
  """
  @spec users() :: Request.t
  def users() do
    %Request{
      endpoint: :user,
            system_only: true,   # or just /_api? Same thing?
      http_method: :get,
      path: "user",
      ok_decoder: __MODULE__.UserDecoder,
    }
  end

  @doc """
  Fetch User

  GET /_api/user/{user}
  """
  @spec user(String.t | t) :: Request.t
  def user(%__MODULE__{user: name}), do: user(name)
  def user(name) do
    %Request{
      endpoint: :user,
      system_only: true,   # or just /_api? Same thing?
      http_method: :get,
      path: "user/#{name}",
      ok_decoder: __MODULE__.UserDecoder,
    }
  end

  @doc """
  Update User

  PATCH /_api/user/{user}
  """
  @spec update(t) :: Request.t
  def update(user, opts \\ []) do
    properties = Utils.opts_to_vars(opts, [:passwd, :active, :extra])

    %Request{
      endpoint: :user,
      system_only: true,   # or just /_api? Same thing?
      http_method: :patch,
      path: "user/#{user.user}",
      body: properties,
      ok_decoder: __MODULE__.UserDecoder,
    }
  end

  @doc """
  Replace User

  PUT /_api/user/{user}
  """
  @spec replace(t) :: Request.t
  def replace(user, opts \\ []) do
    properties = Utils.opts_to_vars(opts, [:passwd, :active, :extra])

    %Request{
      endpoint: :user,
      system_only: true,   # or just /_api? Same thing?
      http_method: :put,
      path: "user/#{user.user}",
      body: properties,
      ok_decoder: __MODULE__.UserDecoder,
    }
  end

  @doc """
  List the databases available to a User

  GET /_api/user/{user}/database
  """
  @spec databases(String.t | t) :: Request.t
  def databases(%__MODULE__{user: name}), do: databases(name)
  def databases(user_name) do
    %Request{
      endpoint: :user,
      system_only: true,   # or just /_api? Same thing?
      http_method: :get,
      path: "user/#{user_name}/database",
      ok_decoder: __MODULE__.PlainDecoder,
    }
  end

  @doc """
  Grant database access

  PUT /_api/user/{user}/database/{dbname}
  """
  @spec grant(t, Database.t) :: Request.t
  def grant(%__MODULE__{user: user_name}, database_name), do: grant(user_name, database_name)
  def grant(user_name, database_name) do
    %Request{
      endpoint: :user,
      system_only: true,   # or just /_api? Same thing?
      http_method: :put,
      path: "user/#{user_name}/database/#{database_name}",
      body: %{grant: "rw"},
    }
  end

  @doc """
  Revoke database access

  PUT /_api/user/{user}/database/{dbname}
  """
  @spec revoke(t, Database.t) :: Request.t
  def revoke(%__MODULE__{user: user_name}, database_name), do: revoke(user_name, database_name)
  def revoke(user_name, database_name) do
    %Request{
      endpoint: :user,
      system_only: true,   # or just /_api? Same thing?
      http_method: :put,
      path: "user/#{user_name}/database/#{database_name}",
      body: %{grant: "none"},
    }
  end

  defmodule UserDecoder do
    alias Arango.User

    @spec decode_ok(map()) :: Arango.ok_error(User.t)
    def decode_ok(%{"result" => result}) when is_list(result), do: {:ok, Enum.map(result, &User.new(&1))}
    def decode_ok(result), do: {:ok, User.new(result)}
  end

  defmodule PlainDecoder do
    @spec decode_ok(map()) :: Arango.ok_error(any())
    def decode_ok(%{"result" => %{} = result}), do: {:ok, result}
    def decode_ok(%{"result" => result}), do: {:ok, result}
  end
end
