defmodule Challenge.Wallet.Worker do
  @moduledoc """
    This GenServer implements wallet APIs and store data user-wise.
  """
  use GenServer

  alias Challenge.Models.Bet
  alias Challenge.Models.User
  alias Challenge.Models.Win

  require Logger

  defmodule State do
    @moduledoc false
    defstruct user: nil, bets: %{}, wins: %{}
  end

  @spec start_link(list()) :: {:ok, pid()} | {:error, any()}
  def start_link([server, user]) do
    GenServer.start_link(__MODULE__, user, name: via_tuple(server, user.name))
  end

  @spec place_bet(server :: pid(), bet_data :: map()) :: {:ok, map} | {:error, any()}
  def place_bet(server, bet_data) do
    GenServer.call(via_tuple(server, bet_data.user), {:place_bet, bet_data})
  end

  @spec won_bet(server :: pid(), win_data :: map()) :: {:ok, map} | {:error, any()}
  def won_bet(server, win_data) do
    GenServer.call(via_tuple(server, win_data.user), {:won_bet, win_data})
  end

  @impl true
  def init(user) do
    Logger.info("Initializing Worker with user: #{user.name}")
    {:ok, %State{user: user}}
  end

  @impl true
  def handle_call({:get_state}, _from, %State{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:place_bet, %Bet{} = bet_data}, _from, %State{} = state) do
    %State{user: user, bets: bets} = state
    %User{amount: amount, currency: currency} = user

    %Bet{amount: bet_amount, transaction_uuid: transaction_uuid, currency: bet_currency} =
      bet_data

    with {:has_currency?, true} <- {:has_currency?, has_currency?(currency, bet_currency)},
         {:txs_exist?, false} <- {:txs_exist?, txs_exist?(bets, transaction_uuid)},
         {:sufficient_balance?, true} <-
           {:sufficient_balance?, sufficient_balance?(amount, bet_amount)} do
      updated_amount = amount - bet_amount

      user = Map.put(user, :amount, updated_amount)
      bets = Map.put(bets, transaction_uuid, bet_data)
      response = format_response(updated_amount, bet_data)

      {:reply, response, %{state | user: user, bets: bets}}
    else
      {:has_currency?, false} ->
        {:reply, {:error, :wrong_currency}, state}

      {:txs_exist?, true} ->
        {:reply, {:error, :duplicate_transaction}, state}

      {:sufficient_balance?, false} ->
        {:reply, {:error, :not_enough_money}, state}
    end
  end

  def handle_call({:won_bet, %Win{} = win_data}, _from, %State{} = state) do
    %State{user: user, bets: bets, wins: wins} = state
    %User{amount: amount, currency: currency} = user

    %Win{
      amount: won_amount,
      transaction_uuid: transaction_uuid,
      currency: win_currency,
      reference_transaction_uuid: reference_txs_id
    } = win_data

    with {:has_currency?, true} <- {:has_currency?, has_currency?(currency, win_currency)},
         {:txs_exist?, false} <- {:txs_exist?, txs_exist?(wins, transaction_uuid)},
         {:reference_txs_exists?, true} <-
           {:reference_txs_exists?, reference_txs_exists?(bets, reference_txs_id)} do
      updated_amount = amount + won_amount

      user = Map.put(user, :amount, updated_amount)
      wins = Map.put(wins, transaction_uuid, win_data)
      response = format_response(updated_amount, win_data)

      {:reply, response, %{state | user: user, wins: wins}}
    else
      {:has_currency?, false} ->
        {:reply, {:error, :wrong_currency}, state}

      {:txs_exist?, true} ->
        {:reply, {:error, :duplicate_transaction}, state}

      {:reference_txs_exists?, false} ->
        {:reply, {:error, :txs_does_not_exist}, state}
    end
  end

  defp sufficient_balance?(amount, bet_amount) when amount >= bet_amount, do: true
  defp sufficient_balance?(_amount, _bet_amount), do: false

  defp has_currency?(currency, state_currency), do: currency == state_currency

  defp txs_exist?(data, transaction_uuid), do: Map.has_key?(data, transaction_uuid)

  defp reference_txs_exists?(bets, reference_txs_id), do: Map.has_key?(bets, reference_txs_id)

  defp format_response(balance, data) do
    {:ok,
     %{
       user: data.user,
       status: "RS_OK",
       request_uuid: data.request_uuid,
       currency: data.currency,
       balance: balance
     }}
  end

  defp via_tuple(server, user_name),
    do: {:via, Registry, {Challenge.Registry, :erlang.term_to_binary({server, user_name})}}
end
