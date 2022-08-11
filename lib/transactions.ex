defmodule Challenge.Transactions do
  @moduledoc false
  use GenServer, restart: :transient

  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def bet_txs_exists?(txs_id) do
    GenServer.call(__MODULE__, {:bet_txs_exists?, txs_id})
  end

  def win_txs_exists?(txs_id) do
    GenServer.call(__MODULE__, {:win_txs_exists?, txs_id})
  end

  def add_bet_txs_id(txs_id) do
    GenServer.cast(__MODULE__, {:add_bet_txs_id, txs_id})
  end

  def add_win_txs_id(txs_id) do
    GenServer.cast(__MODULE__, {:add_win_txs_id, txs_id})
  end

  @impl true
  def init([]) do
    Logger.info("Initializing Transactions..")
    {:ok, %{bet_txs_ids: MapSet.new(), win_txs_ids: MapSet.new()}}
  end

  @impl true
  def handle_call({:bet_txs_exists?, txs_id}, _from, %{bet_txs_ids: txs_ids} = state) do
    {:reply, MapSet.member?(txs_ids, txs_id), state}
  end

  def handle_call({:win_txs_exists?, txs_id}, _from, %{win_txs_ids: txs_ids} = state) do
    {:reply, MapSet.member?(txs_ids, txs_id), state}
  end

  @impl true
  def handle_cast({:add_bet_txs_id, new_txs_id}, %{bet_txs_ids: txs_ids} = state) do
    {:noreply, %{state | bet_txs_ids: MapSet.put(txs_ids, new_txs_id)}}
  end

  @impl true
  def handle_cast({:add_win_txs_id, new_txs_id}, %{win_txs_ids: txs_ids} = state) do
    {:noreply, %{state | win_txs_ids: MapSet.put(txs_ids, new_txs_id)}}
  end
end
