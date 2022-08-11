defmodule Challenge do
  @moduledoc """
  Documentation for `Challenge`.
  """
  use Application

  alias Challenge.Supervisor
  alias Challenge.Request.Manager, as: RequestManager
  alias Challenge.Request.Server, as: RequestServer

  @doc """
  Start a linked and isolated supervision tree and returns the root server that
  will handle the requests.
  """
  @spec start :: GenServer.server()
  def start() do
    {:ok, pid} = RequestManager.start_child()
    pid
  end

  def start(_type, _args) do
    Supervisor.start_link()
  end

  @doc """
  Create non-existing users with currency as "USD" and amount as 100_000.

  It ignores any entry that is NOT a non-empty binary or if the user already exists.
  """
  @spec create_users(server :: GenServer.server(), users :: [String.t()]) :: :ok
  def create_users(server, users) do
    RequestServer.create_users(server, users)
  end

  @doc """
  The same behavior from `POST /transaction/bet` docs.

  The `body` parameter is the "body" from the docs as a map with keys as atoms.
  The result is the "response" from the docs as a map with keys as atoms.
  """
  @spec bet(server :: GenServer.server(), body :: map) :: map
  def bet(server, body) do
    RequestServer.bet(server, body)
  end

  @doc """
  The same behavior from `POST /transaction/win` docs.

  The `body` parameter is the "body" from the docs as a map with keys as atoms.
  The result is the "response" from the docs as a map with keys as atoms.
  """
  @spec win(server :: GenServer.server(), body :: map) :: map
  def win(server, body) do
    RequestServer.win(server, body)
  end
end
