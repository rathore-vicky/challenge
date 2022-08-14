defmodule Challenge.Wallet.WorkerTest do
  use ExUnit.Case, async: false

  alias Challenge
  alias Challenge.Models.{Bet, User, Win}
  alias Challenge.Wallet.Worker, as: WalletWorker
  alias Test.Support.ChallengeHelper

  describe "start_link/1" do
    setup do
      server = Challenge.start()
      {:ok, server: server}
    end

    test "successfully create a new worker", %{server: server} do
      assert {:ok, %User{} = user} = User.new("test_user")
      assert {:ok, pid} = WalletWorker.start_link([server, user])
      assert is_pid(pid)
      assert %{user: ^user, bets: %{}, wins: %{}} = :sys.get_state(pid)
    end
  end

  describe "place_bet/2" do
    setup do
      server = Challenge.start()
      {:ok, bet_data} = ChallengeHelper.bet_data() |> Bet.new()

      create_user(server, bet_data.user)

      {:ok, server: server, data: bet_data}
    end

    test "returns error if user doesn't have currency", %{server: server, data: data} do
      bet_currency = "EUR"
      bet_data = %{data | currency: bet_currency}

      assert {:error, :wrong_currency} == WalletWorker.place_bet(server, bet_data)
    end

    test "returns error if user doesn't have sufficient balance", %{server: server, data: data} do
      bet_amount = 100_001
      bet_data = %{data | amount: bet_amount}

      assert {:error, :not_enough_money} = WalletWorker.place_bet(server, bet_data)
    end

    test "sucessfully place bet", %{server: server, data: data} do
      %{
        user: user,
        request_uuid: request_uuid,
        currency: currency,
        amount: amount
      } = data

      rem_balance = 100_000 - amount

      assert {:ok,
              %{
                user: ^user,
                status: "RS_OK",
                request_uuid: ^request_uuid,
                currency: ^currency,
                balance: ^rem_balance
              } = _bet} = WalletWorker.place_bet(server, data)
    end
  end

  describe "won_bet/2" do
    setup do
      server = Challenge.start()
      {:ok, win_data} = ChallengeHelper.win_data() |> Win.new()

      create_user(server, win_data.user)

      {:ok, server: server, data: win_data}
    end

    test "returns error if user doesn't have currency", %{server: server, data: data} do
      win_currency = "EUR"
      win_data = %{data | currency: win_currency}

      assert {:error, :wrong_currency} == WalletWorker.won_bet(server, win_data)
    end

    test "returns error if user bet doesn't exist", %{server: server, data: data} do
      assert {:error, :txs_does_not_exist} = WalletWorker.won_bet(server, data)
    end

    test "sucessfully reflect win bet", %{server: server, data: win_data} do
      bet_data = ChallengeHelper.bet_data()
      Challenge.bet(server, bet_data)

      %{
        user: user,
        request_uuid: request_uuid,
        currency: currency,
        amount: amount
      } = win_data

      rem_balance = 100_000 - bet_data.amount + amount

      assert {:ok,
              %{
                user: ^user,
                status: "RS_OK",
                request_uuid: ^request_uuid,
                currency: ^currency,
                balance: ^rem_balance
              }} = WalletWorker.won_bet(server, win_data)
    end
  end

  defp create_user(server, user) do
    Challenge.create_users(server, [user])
  end
end
