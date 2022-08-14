defmodule Challenge.Models.Bet do
  @moduledoc """
    This Module validates bet APIs parameters.
  """

  alias Challenge.Validation

  @enforce_keys [
    :supplier_user,
    :transaction_uuid,
    :token,
    :round_closed,
    :round,
    :reward_uuid,
    :request_uuid,
    :is_free,
    :game_id,
    :game_code,
    :currency,
    :bet,
    :amount,
    :meta
  ]

  defstruct [
    :supplier_user,
    :user,
    :transaction_uuid,
    :token,
    :round_closed,
    :round,
    :reward_uuid,
    :request_uuid,
    :is_free,
    :game_id,
    :game_code,
    :currency,
    :bet,
    :amount,
    :meta
  ]

  @types [
    supplier_user: :uuid,
    transaction_uuid: :uuid,
    token: :token,
    round_closed: :boolean,
    round: :string,
    reward_uuid: :uuid,
    request_uuid: :uuid,
    is_free: :boolean,
    game_id: :integer,
    game_code: :string,
    currency: :string,
    bet: :string,
    amount: :integer,
    meta: :map
  ]

  def new(%{
        supplier_user: supplier_user,
        transaction_uuid: transaction_uuid,
        token: token,
        round_closed: round_closed,
        round: round,
        reward_uuid: reward_uuid,
        request_uuid: request_uuid,
        is_free: is_free,
        game_id: game_id,
        game_code: game_code,
        currency: currency,
        bet: bet,
        amount: amount,
        meta: meta
      }) do
    %__MODULE__{
      supplier_user: supplier_user,
      transaction_uuid: transaction_uuid,
      token: token,
      round_closed: round_closed,
      round: round,
      reward_uuid: reward_uuid,
      request_uuid: request_uuid,
      is_free: is_free,
      game_id: game_id,
      game_code: game_code,
      currency: currency,
      bet: bet,
      amount: amount,
      meta: meta
    }
    |> Validation.validate(@types)
  end

  def new(_), do: {:error, :invalid_data}
end
