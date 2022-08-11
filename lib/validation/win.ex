defmodule Challenge.Validation.Win do
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
    reference_transaction_uuid: :binary,
    is_free: :boolean,
    game_id: :integer,
    game_code: :binary,
    currency: :string,
    bet: :binary,
    amount: :integer,
    meta: :map
  ]

  @required_fields [
    :supplier_user,
    :transaction_uuid,
    :currency,
    :amount,
    :reference_transaction_uuid
  ]

  def validate(params), do: Validation.validate_params(@fields, params, @required_fields)
end
