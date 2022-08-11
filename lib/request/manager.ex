defmodule Challenge.Request.Manager do
  @moduledoc false
  use DynamicSupervisor

  alias Challenge.Request.Server

  require Logger

  def start_link(_) do
    Logger.info("Starting Request Manager...")
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(request_id \\ 1) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Server, request_id}
    )
  end
end
