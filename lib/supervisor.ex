defmodule Challenge.Supervisor do
  @moduledoc false
  use Supervisor

  alias Challenge.Request.Manager, as: RequestManager
  alias Challenge.User.Supervisor, as: UserSupervisor

  require Logger

  def start_link() do
    Logger.info("Starting Supervisor...")
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    children = [
      {DynamicSupervisor, name: RequestManager, strategy: :one_for_one},
      {DynamicSupervisor, name: UserSupervisor, strategy: :one_for_one},
      Challenge.Transactions,
      Challenge.Registry
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
