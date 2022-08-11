defmodule Challenge.User.Supervisor do
  @moduledoc false
  use DynamicSupervisor

  alias Challenge.User.Server

  require Logger

  def start_link(_) do
    Logger.info("Starting User Supervisor...")
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(user_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Server, user_name}
    )
  end
end
