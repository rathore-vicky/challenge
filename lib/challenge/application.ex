defmodule Challenge.Application do
  @moduledoc """
    Application for Challenge.
  """
  use Application

  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: Challenge.Registry]}
    ]

    opts = [strategy: :one_for_one, name: Challenge.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
