defmodule Challenge.Wallet.Supervisor do
  @moduledoc false
  use DynamicSupervisor

  alias Challenge.Models.User
  alias Challenge.Wallet.Worker

  require Logger

  @spec start_link(opts :: list()) :: {:ok, pid()} | {:error, any()}
  def start_link(opts \\ []) do
    Logger.info("Starting RequestSupervisor...")
    DynamicSupervisor.start_link(__MODULE__, opts)
  end

  @spec create_users(server :: pid(), users :: list()) :: :ok
  def create_users(server, users) when is_list(users) do
    Enum.each(users, &create_user(server, &1))
  end

  def create_users(_server, _users), do: :ok

  @spec bet(server :: pid(), bet_data :: map()) :: {:ok, map()} | {:error, any()}
  def bet(server, bet_data) do
    with {:user_exist?, true} <- {:user_exist?, user_exist?(server, bet_data.user)},
         {:ok, response} <- Worker.place_bet(server, bet_data) do
      {:ok, response}
    else
      {:user_exist?, false} ->
        {:error, :unknown_error}

      error ->
        error
    end
  end

  @spec win(server :: pid(), win_data :: map()) :: {:ok, map()} | {:error, any()}
  def win(server, win_data) do
    with {:user_exist?, true} <- {:user_exist?, user_exist?(server, win_data.user)},
         {:ok, response} <- Worker.won_bet(server, win_data) do
      {:ok, response}
    else
      {:user_exist?, false} ->
        {:error, :unknown_error}

      error ->
        error
    end
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp start_child(server, specs) do
    DynamicSupervisor.start_child(server, specs)
  end

  defp create_user(server, user_name) do
    with {:ok, %User{} = user} <- User.new(user_name),
         {:user_exist?, false} <- {:user_exist?, user_exist?(server, user_name)},
         {:ok, _pid} <- start_child(server, {Worker, [server, user]}) do
      :ok
    else
      error ->
        Logger.debug("Create user failed error: #{inspect(error)}")
        :ok
    end
  end

  defp user_exist?(server, user_name), do: !is_nil(lookup(server, user_name))

  defp lookup(server, user_name) do
    case Registry.lookup(Challenge.Registry, :erlang.term_to_binary({server, user_name})) do
      [{pid, _}] ->
        pid

      _ ->
        nil
    end
  end
end
