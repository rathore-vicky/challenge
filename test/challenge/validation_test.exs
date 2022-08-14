defmodule Challenge.ValidationTest do
  use ExUnit.Case

  alias Challenge.Models.{Bet, User, Win}
  alias Challenge.Validation
  alias Test.Support.ChallengeHelper

  @bet_keys ChallengeHelper.bet_data() |> Map.keys() |> List.delete([:__struct__])
  @win_keys ChallengeHelper.bet_data() |> Map.keys() |> List.delete([:__struct__])

  describe "validate_user/1" do
    test "return error when user_name is integer" do
      assert {:error, :invalid_type} == Validation.validate_user(1)
    end

    test "succesfully validate user when user_name is string" do
      user_name = "test"

      assert {:ok, %User{name: ^user_name, currency: "USD", amount: 100_000}} =
               Validation.validate_user(user_name)
    end
  end

  describe "validate_bet/1" do
    setup do
      bet_data = ChallengeHelper.bet_data()
      {:ok, data: bet_data}
    end

    test "returns error when bet_data is empty" do
      assert {:error, :invalid_data} == Validation.validate_bet(%{})
    end

    for field <- @bet_keys do
      test "returns error when required field #{field} isn't provided", %{data: data} do
        assert {:error, :invalid_data} ==
                 Validation.validate_bet(Map.delete(data, unquote(field)))
      end

      test "returns error when required field #{field} hasn't expected type", %{data: data} do
        assert {:error, :wrong_type} ==
                 Validation.validate_bet(Map.put(data, unquote(field), :test))
      end
    end

    test "succesfully validates bet when data is valid", %{data: data} do
      %{
        supplier_user: supplier_user,
        transaction_uuid: transaction_uuid,
        currency: currency,
        amount: amount
      } = data

      assert {:ok,
              %Bet{
                supplier_user: ^supplier_user,
                transaction_uuid: ^transaction_uuid,
                currency: ^currency,
                amount: ^amount
              }} = Validation.validate_bet(data)
    end
  end

  describe "validate_win/1" do
    setup do
      win_data = ChallengeHelper.win_data()
      {:ok, data: win_data}
    end

    test "returns error when win_data is empty" do
      assert {:error, :invalid_data} == Validation.validate_win(%{})
    end

    for field <- @win_keys do
      test "returns error when required field #{field} isn't provided", %{data: data} do
        assert {:error, :invalid_data} ==
                 Validation.validate_win(Map.delete(data, unquote(field)))
      end

      test "returns error when required field #{field} hasn't expected type", %{data: data} do
        assert {:error, :wrong_type} ==
                 Validation.validate_win(Map.put(data, unquote(field), :test))
      end
    end

    test "succesfully validates win when data is valid", %{data: data} do
      %{
        supplier_user: supplier_user,
        transaction_uuid: transaction_uuid,
        currency: currency,
        amount: amount,
        reference_transaction_uuid: reference_transaction_uuid
      } = data

      assert {:ok,
              %Win{
                supplier_user: ^supplier_user,
                transaction_uuid: ^transaction_uuid,
                currency: ^currency,
                amount: ^amount,
                reference_transaction_uuid: ^reference_transaction_uuid
              }} = Validation.validate_win(data)
    end
  end
end
