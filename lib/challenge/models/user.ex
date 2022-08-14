defmodule Challenge.Models.User do
  @moduledoc false

  @enforce_keys [
    :name
  ]

  defstruct name: nil, currency: "USD", amount: 100_000

  @type t :: %__MODULE__{
          name: String.t(),
          currency: String.t(),
          amount: Decimal.t()
        }

  @spec new(user_name :: String.t()) :: Challenge.Models.User.t() | {:error, :invalid_type}
  def new(user_name) when is_binary(user_name) and byte_size(user_name) > 2 do
    {:ok, %__MODULE__{name: user_name}}
  end

  def new(_), do: {:error, :invalid_type}
end
