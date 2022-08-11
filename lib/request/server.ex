defmodule Challenge.Request.Server do
  @moduledoc false
  use GenServer

  alias Challenge.Transactions
  alias Challenge.User.Server, as: UserServer
  alias Challenge.Validation

  require Logger

  @type error_type ::
          {:error,
           :RS_OK
           | :RS_ERROR_UNKNOWN
           | :RS_ERROR_INVALID_PARTNER
           | :RS_ERROR_INVALID_TOKEN
           | :RS_ERROR_INVALID_GAME
           | :RS_ERROR_WRONG_CURRENCY
           | :RS_ERROR_NOT_ENOUGH_MONEY
           | :RS_ERROR_USER_DISABLED
           | :RS_ERROR_INVALID_SIGNATURE
           | :RS_ERROR_TOKEN_EXPIRED
           | :RS_ERROR_WRONG_SYNTAX
           | :RS_ERROR_WRONG_TYPES
           | :RS_ERROR_DUPLICATE_TRANSACTION
           | :RS_ERROR_TRANSACTION_DOES_NOT_EXIST}

  defmodule State do
    defstruct [:request_id]
  end

  ################################################################################
  ## API Functions
  ################################################################################
  def start_link(request_id) do
    GenServer.start_link(__MODULE__, request_id, name: via_tuple(request_id))
  end

  def create_users(server, users) when is_list(users) do
    GenServer.cast(server, {:create_users, users})
  end

  def create_users(_server, _users), do: :ok

  def bet(server, body) do
    with {:ok, bet_data} <- Validation.validate_bet(body),
         {:user_exists?, true} <- {:user_exists?, UserServer.exists?(bet_data.user)},
         {:txs_exists?, false} <-
           {:txs_exists?, Transactions.bet_txs_exists?(bet_data.transaction_uuid)},
         {:ok, response} <- GenServer.call(server, {:place_bet, bet_data}) do
      response
    else
      error ->
        handle_common_errors(error)
    end
  end

  def win(server, body) do
    with {:ok, win_data} <- Validation.validate_win(body),
         {:user_exists?, true} <- {:user_exists?, UserServer.exists?(win_data.user)},
         {:txs_exists?, false} <-
           {:txs_exists?, Transactions.win_txs_exists?(win_data.transaction_uuid)},
         {:ok, response} <- GenServer.call(server, {:win_bet, win_data}) do
      response
    else
      error ->
        handle_common_errors(error)
    end
  end

  ################################################################################
  ## Callback Functions
  ################################################################################

  @impl true
  def init(request_id) do
    Logger.info("Initializing Request #{request_id}")
    {:ok, %State{request_id: request_id}}
  end

  @impl true
  def handle_call({:place_bet, bet_data}, _from, %State{} = state) do
    {:reply, UserServer.place_bet(bet_data), state}
  end

  @impl true
  def handle_call({:win_bet, win_data}, _from, %State{} = state) do
    {:reply, UserServer.won_bet(win_data), state}
  end

  @impl true
  def handle_cast({:create_users, users}, %State{} = state) do
    Enum.each(users, &UserServer.create/1)
    {:noreply, state}
  end

  ################################################################################
  ## Internal Functions
  ################################################################################


  defp via_tuple(request_id) do
    Challenge.Registry.via_tuple({__MODULE__, request_id})
  end

  defp handle_common_errors({:error, :invalid_type}), do: {:error, :RS_ERROR_WRONG_TYPES}
  defp handle_common_errors({:error, :is_required}), do: {:error, :RS_ERROR_WRONG_SYNTAX}
  defp handle_common_errors({:user_exists?, false}), do: {:error, :RS_ERROR_INVALID_PARTNER}
  defp handle_common_errors({:has_currency?, false}), do: {:error, :RS_ERROR_WRONG_CURRENCY}
  defp handle_common_errors({:txs_exists?, true}), do: {:error, :RS_ERROR_DUPLICATE_TRANSACTION}

  defp handle_common_errors({:sufficient_balance?, false}),
    do: {:error, :RS_ERROR_NOT_ENOUGH_MONEY}

  defp handle_common_errors({:reference_txs_exists?, false}),
    do: {:error, :RS_ERROR_TRANSACTION_DOES_NOT_EXIST}

  defp handle_common_errors({:error, _error}), do: {:error, :RS_ERROR_UNKNOWN}
end
