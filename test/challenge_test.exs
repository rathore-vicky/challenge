defmodule ChallengeTest do
  use ExUnit.Case
  doctest Challenge

  alias Challenge
  alias Test.Support.ChallengeHelper

  describe "start/0" do
    test "start root server to handle requests" do
      assert server = Challenge.start()
      assert is_pid(server)
      assert Process.alive?(server)
    end
  end

  describe "create_users/2" do
    setup do
      server = Challenge.start()
      {:ok, server: server}
    end

    test "returns :ok and doesn't create users when users are not list", %{server: server} do
      assert :ok = Challenge.create_users(server, :user1)
      assert [] == Registry.lookup(Challenge.Registry, :erlang.term_to_binary({server, :user1}))

      assert :ok = Challenge.create_users(server, {"user1", "user2"})
      assert [] == Registry.lookup(Challenge.Registry, :erlang.term_to_binary({server, "user1"}))
      assert [] == Registry.lookup(Challenge.Registry, :erlang.term_to_binary({server, "user2"}))
    end

    test "returns :ok and doesn't create users when users invalid", %{server: server} do
      users = [:test, 123]
      assert :ok = Challenge.create_users(server, users)

      assert [] == Registry.lookup(Challenge.Registry, :erlang.term_to_binary({server, :test}))
      assert [] == Registry.lookup(Challenge.Registry, :erlang.term_to_binary({server, 123}))
    end

    test "returns :ok and doesn't create user when user already exist", %{server: server} do
      user = "test"
      assert :ok = Challenge.create_users(server, [user])

      assert [{pid, _}] =
               Registry.lookup(Challenge.Registry, :erlang.term_to_binary({server, user}))

      assert :ok = Challenge.create_users(server, [user])

      assert [{^pid, _}] =
               Registry.lookup(Challenge.Registry, :erlang.term_to_binary({server, user}))
    end

    test "sucessfully create users when users are valid", %{server: server} do
      assert :ok = Challenge.create_users(server, ["user1", "user2"])

      assert [{pid, _}] =
               Registry.lookup(Challenge.Registry, :erlang.term_to_binary({server, "user1"}))

      assert is_pid(pid)

      assert [{pid, _}] =
               Registry.lookup(Challenge.Registry, :erlang.term_to_binary({server, "user2"}))

      assert is_pid(pid)
    end
  end

  describe "bet/2" do
    setup do
      server = Challenge.start()
      data = ChallengeHelper.bet_data()
      {:ok, server: server, data: data}
    end

    test "returns error if invalid data", %{server: server, data: data} do
      data = Map.delete(data, :supplier_user)
      assert %{status: "RS_ERROR_WRONG_SYNTAX"} == Challenge.bet(server, data)
    end

    test "returns error if wrong type", %{server: server, data: data} do
      data = Map.put(data, :supplier_user, :test_user)
      assert %{status: "RS_ERROR_WRONG_TYPES"} == Challenge.bet(server, data)
    end

    test "returns error if user doesn't exist", %{server: server, data: data} do
      assert %{status: "RS_ERROR_UNKNOWN"} == Challenge.bet(server, data)
    end

    test "sucessfully reflect bet", %{server: server, data: data} do
      %{
        supplier_user: supplier_user,
        request_uuid: request_uuid,
        currency: currency,
        amount: amount
      } = data

      user_name = String.trim(supplier_user, "hub88_")
      balance = 100_000 - amount

      Challenge.create_users(server, [user_name])

      assert %{
               status: "RS_OK",
               user: ^user_name,
               balance: ^balance,
               currency: ^currency,
               request_uuid: ^request_uuid
             } = Challenge.bet(server, data)
    end

    test "returns error if txs_id is duplicate", %{server: server, data: data} do
      user_name = Map.get(data, :supplier_user) |> String.trim("hub88_")

      Challenge.create_users(server, [user_name])
      assert %{status: "RS_OK"} = Challenge.bet(server, data)

      assert %{status: "RS_ERROR_DUPLICATE_TRANSACTION"} == Challenge.bet(server, data)
    end

    test "returns error if server is different", %{server: server, data: data} do
      user_name = Map.get(data, :supplier_user) |> String.trim("hub88_")

      Challenge.create_users(server, [user_name])

      new_server = Challenge.start()

      assert %{status: "RS_ERROR_UNKNOWN"} = Challenge.bet(new_server, data)
    end
  end

  describe "win/2" do
    setup do
      server = Challenge.start()
      data = ChallengeHelper.win_data()
      {:ok, server: server, data: data}
    end

    test "returns error if invalid data", %{server: server, data: data} do
      data = Map.delete(data, :supplier_user)
      assert %{status: "RS_ERROR_WRONG_SYNTAX"} == Challenge.win(server, data)
    end

    test "returns error if wrong type", %{server: server, data: data} do
      data = Map.put(data, :supplier_user, :test_user)
      assert %{status: "RS_ERROR_WRONG_TYPES"} == Challenge.win(server, data)
    end

    test "returns error if user doesn't exist", %{server: server, data: data} do
      assert %{status: "RS_ERROR_UNKNOWN"} == Challenge.win(server, data)
    end

    test "returns error if bet txs_id doesn't exist", %{server: server, data: data} do
      user_name = Map.get(data, :supplier_user) |> String.trim("hub88_")
      Challenge.create_users(server, [user_name])

      assert %{status: "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"} == Challenge.win(server, data)
    end

    test "sucessfully reflect win", %{server: server, data: data} do
      %{
        supplier_user: supplier_user,
        request_uuid: request_uuid,
        currency: currency,
        amount: won_amount
      } = data

      bet_data = ChallengeHelper.bet_data()

      user_name = String.trim(supplier_user, "hub88_")

      Challenge.create_users(server, [user_name])
      Challenge.bet(server, bet_data)
      balance = 100_000 - bet_data.amount + won_amount

      assert %{
               status: "RS_OK",
               user: ^user_name,
               balance: ^balance,
               currency: ^currency,
               request_uuid: ^request_uuid
             } = Challenge.win(server, data)
    end

    test "returns error if txs_id is duplicate", %{server: server, data: data} do
      user_name = Map.get(data, :supplier_user) |> String.trim("hub88_")

      Challenge.create_users(server, [user_name])
      Challenge.bet(server, ChallengeHelper.bet_data())

      assert %{status: "RS_OK"} = Challenge.win(server, data)

      assert %{status: "RS_ERROR_DUPLICATE_TRANSACTION"} == Challenge.win(server, data)
    end

    test "returns error if server is different", %{server: server, data: data} do
      user_name = Map.get(data, :supplier_user) |> String.trim("hub88_")

      Challenge.create_users(server, [user_name])

      new_server = Challenge.start()

      assert %{status: "RS_ERROR_UNKNOWN"} = Challenge.win(new_server, data)
    end
  end
end
