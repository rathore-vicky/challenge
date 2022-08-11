defmodule Challenge.User.Server do
  @moduledoc false
  use GenServer

  alias Challenge.Transactions
  alias Challenge.Validation
  alias Challenge.User.Supervisor, as: UserSupervisor

  require Logger

  defmodule State do
    defstruct [:name, :amount, :currency]
  end

  def start_link(user_name) do
    GenServer.start_link(__MODULE__, user_name, name: via_tuple(user_name))
  end

  def create(user_name) do
    with :ok <- Validation.validate_user(user_name),
         true <- is_nil(lookup(user_name)),
         {:ok, _pid} <- UserSupervisor.start_child(user_name) do
      :ok
    else
      error ->
        Logger.debug("Create user failed error: #{inspect(error)}")
        :ok
    end
  end

  def exists?(user_name) do
    case lookup(user_name) do
      nil -> false
      _pid -> true
    end
  end

  def place_bet(bet_data) do
    GenServer.call(via_tuple(bet_data.user), {:place_bet, bet_data})
  end

  def won_bet(win_data) do
    GenServer.call(via_tuple(win_data.user), {:won_bet, win_data})
  end

  def get_state(user_name) do
    GenServer.call(via_tuple(user_name), {:get_state})
  end

  @impl true
  def init(user_name) do
    Logger.info("Initializing User...", user_name: user_name)
    {:ok, %State{name: user_name, amount: 100_000, currency: "USD"}}
  end

  @impl true
  def handle_call({:get_state}, _from, %State{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:place_bet, bet_data}, _from, %State{amount: amount} = state) do
    %{amount: bet_amount, transaction_uuid: txs_id, currency: currency} = bet_data

    with {:sufficient_balance?, true} <-
           {:sufficient_balance?, sufficient_balance?(amount, bet_amount)},
         {:has_currency?, true} <- {:has_currency?, has_currency?(currency, state.currency)} do
      Transactions.add_bet_txs_id(txs_id)
      updated_balance = amount - bet_amount
      response = format_response(updated_balance, bet_data)

      {:reply, response, %{state | amount: updated_balance}}
    else
      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:won_bet, win_data}, _from, %State{amount: amount} = state) do
    %{
      amount: won_amount,
      transaction_uuid: txs_id,
      reference_transaction_uuid: reference_txs_id,
      currency: currency
    } = win_data

    with {:has_currency?, true} <- {:has_currency?, has_currency?(currency, state.currency)},
         {:reference_txs_exists?, true} <-
           {:reference_txs_exists?, reference_txs_exists?(reference_txs_id)} do
      Transactions.add_win_txs_id(txs_id)

      updated_balance = amount + won_amount
      response = format_response(updated_balance, win_data)
      {:reply, response, %{state | amount: updated_balance}}
    else
      error ->
        {:reply, error, state}
    end
  end

  defp sufficient_balance?(amount, bet_amount) when amount >= bet_amount, do: true
  defp sufficient_balance?(_amount, _bet_amount), do: false

  defp has_currency?(currency, state_currency), do: currency == state_currency

  defp reference_txs_exists?(reference_txs_id), do: Transactions.bet_txs_exists?(reference_txs_id)

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

  # defp via_tuple(user_name) do
  #   {:via, Registry, {Registry.User, user_name}}
  # end

  def via_tuple(user_name) do
    Challenge.Registry.via_tuple({__MODULE__, user_name})
  end

  def lookup(user_name) do
    case Registry.lookup(Challenge.Registry, {__MODULE__, user_name}) do
      [{user_pid, _}] ->
        user_pid
      _ ->
          nil
    end
  end



  # def lookup(user_name) do
  #   case Registry.lookup(Registry.User, user_name) do
  #     [{user_pid, _}] ->
  #       user_pid

  #     _ ->
  #       nil
  #   end
  # end
end
