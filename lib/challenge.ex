defmodule Challenge do
  @moduledoc """
    Documentation for `Challenge` application.
  """

  alias Challenge.Validation
  alias Challenge.Models.{Bet, Win}
  alias Challenge.Wallet.Supervisor, as: WalletSupervisor

  import Challenge.Utils, only: [handle_common_errors: 1]

  @doc """
  Start a linked and isolated supervision tree and returns the root server that
  will handle the requests.

  ## Examples

    iex> Challenge.start()
    #PID<0.167.0>
  """
  @spec start :: GenServer.server()
  def start do
    {:ok, pid} = WalletSupervisor.start_link()
    pid
  end

  @doc """
  Create non-existing users with currency as "USD" and amount as 100_000.

  It ignores any entry that is NOT a non-empty binary or if the user already exists.

  ## Examples

    iex> Challenge.create_users(server, ["user1"])
    :ok
  """
  @spec create_users(server :: GenServer.server(), users :: [String.t()]) :: :ok
  defdelegate create_users(server, users), to: WalletSupervisor

  @doc """
  The same behavior from `POST /transaction/bet` docs.

  The `body` parameter is the "body" from the docs as a map with keys as atoms.
  The result is the "response" from the docs as a map with keys as atoms.

  ## Examples

    iex> Challenge.bet(server, %{
          amount: 10_500,
          bet: "zero",
          currency: "USD",
          game_code: "clt_dragonrising",
          game_id: 132,
          is_free: true,
          meta: %{odds: 2.5, selection: "home_team"},
          request_uuid: "583c985f-fee6-4c0e-bbf5-308aad6265af",
          reward_uuid: "a28f93f2-98c5-41f7-8fbb-967985acf8fe",
          round: "rNEMwgzJAOZ6eR3V",
          round_closed: false,
          supplier_user: "hub88_john12345",
          token: "55b7518e-b89e-11e7-81be-58404eea6d16",
          transaction_uuid: "16d2dcfe-b89e-11e7-854a-58404eea6d16"
        })
    %{
      balance: 89_500,
      currency: "USD",
      request_uuid: "583c985f-fee6-4c0e-bbf5-308aad6265af",
      status: "RS_OK",
      user: "john12345"
    }
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

  ## Examples

    iex> Challenge.bet(server, %{
            amount: 10_500,
            bet: "zero",
            currency: "USD",
            game_code: "clt_dragonrising",
            game_id: 132,
            is_free: true,
            meta: %{odds: 2.5, selection: "home_team"},
            request_uuid: "583c985f-fee6-4c0e-bbf5-308aad6265af",
            reward_uuid: "a28f93f2-98c5-41f7-8fbb-967985acf8fe",
            reference_transaction_uuid: "16d2dcfe-b89e-11e7-854a-58404eea6d16",
            round: "rNEMwgzJAOZ6eR3V",
            round_closed: false,
            supplier_user: "hub88_john12345",
            token: "55b7518e-b89e-11e7-81be-58404eea6d16",
            transaction_uuid: "16d2dcfe-b89e-11e7-854a-58404eea6d16"
          })
      %{
        balance: 100_000,
        currency: "USD",
        request_uuid: "583c985f-fee6-4c0e-bbf5-308aad6265af",
        status: "RS_OK",
        user: "john12345"
      }
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
