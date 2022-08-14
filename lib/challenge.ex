defmodule Challenge do
  @moduledoc """
  Documentation for `Challenge`.
  """

  alias Challenge.Validation
  alias Challenge.Models.{Bet, Win}
  alias Challenge.Wallet.Supervisor, as: WalletSupervisor

  import Challenge.Utils, only: [handle_common_errors: 1]

  @doc """
  Start a linked and isolated supervision tree and returns the root server that
  will handle the requests.
  """
  @spec start :: GenServer.server()
  def start do
    {:ok, pid} = WalletSupervisor.start_link()
    pid
  end

  @doc """
  Create non-existing users with currency as "USD" and amount as 100_000.

  It ignores any entry that is NOT a non-empty binary or if the user already exists.
  """
  @spec create_users(server :: GenServer.server(), users :: [String.t()]) :: :ok
  defdelegate create_users(server, users), to: WalletSupervisor

  @doc """
  The same behavior from `POST /transaction/bet` docs.

  The `body` parameter is the "body" from the docs as a map with keys as atoms.
  The result is the "response" from the docs as a map with keys as atoms.
  """
  @spec bet(server :: GenServer.server(), body :: map) :: map
  def bet(server, body) do
    with {:ok, %Bet{} = bet} <- Validation.validate_bet(body),
         {:ok, response} <- WalletSupervisor.bet(server, bet) do
      response
    else
      error ->
        handle_common_errors(error)
    end
  end

  @doc """
  The same behavior from `POST /transaction/win` docs.

  The `body` parameter is the "body" from the docs as a map with keys as atoms.
  The result is the "response" from the docs as a map with keys as atoms.
  """
  @spec win(server :: GenServer.server(), body :: map) :: map
  def win(server, body) do
    with {:ok, %Win{} = win} <- Validation.validate_win(body),
         {:ok, response} <- WalletSupervisor.win(server, win) do
      response
    else
      error ->
        handle_common_errors(error)
    end
  end
end
