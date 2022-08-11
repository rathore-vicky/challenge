defmodule Challenge.Validation.Bet do
  @moduledoc false

  alias Challenge.Validation

  @fields [
    supplier_user: :binary,
    transaction_uuid: :binary,
    token: :binary,
    round_closed: :boolean,
    round: :binary,
    reward_uuid: :binary,
    request_uuid: :binary,
    is_free: :boolean,
    game_id: :integer,
    game_code: :binary,
    currency: :string,
    bet: :binary,
    amount: :integer,
    meta: :map
  ]

  @required_fields [:supplier_user, :transaction_uuid, :currency, :amount]

  def validate(params), do: Validation.validate_params(@fields, params, @required_fields)
end
