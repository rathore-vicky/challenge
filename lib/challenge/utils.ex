defmodule Challenge.Utils do
  @moduledoc false

  @spec handle_common_errors(tuple()) :: map()
  def handle_common_errors({:error, :wrong_type}), do: %{status: "RS_ERROR_WRONG_TYPES"}
  def handle_common_errors({:error, :invalid_data}), do: %{status: "RS_ERROR_WRONG_SYNTAX"}
  def handle_common_errors({:error, :wrong_currency}), do: %{status: "RS_ERROR_WRONG_CURRENCY"}

  def handle_common_errors({:error, :not_enough_money}),
    do: %{status: "RS_ERROR_NOT_ENOUGH_MONEY"}

  def handle_common_errors({:error, :duplicate_transaction}),
    do: %{status: "RS_ERROR_DUPLICATE_TRANSACTION"}

  def handle_common_errors({:error, :txs_does_not_exist}),
    do: %{status: "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"}

  # will add some more errors here
  def handle_common_errors({:error, _error}), do: %{status: "RS_ERROR_UNKNOWN"}

  @spec validate_type(val :: String.t() | Integer.t() | Boolean.t() | map(), atom()) ::
          :ok | {:error, any()}
  def validate_type(val, :binary) when is_binary(val), do: :ok
  def validate_type(val, :boolean) when is_boolean(val), do: :ok
  def validate_type(val, :integer) when is_integer(val) and val > 0, do: :ok
  def validate_type(val, :float) when is_float(val), do: :ok
  def validate_type(val, :number) when is_number(val), do: :ok
  def validate_type(val, :string) when is_binary(val) and byte_size(val) > 0, do: :ok
  def validate_type(val, :binary) when is_binary(val), do: :ok
  def validate_type(val, :atom) when is_atom(val), do: :ok
  def validate_type(val, :map) when is_map(val), do: :ok
  def validate_type(val, :uuid) when is_binary(val), do: :ok

  def validate_type(val, :token)
      when is_binary(val) and byte_size(val) > 0 and byte_size(val) <= 255,
      do: :ok

  # will add some more validation here
  def validate_type(_, _type), do: {:error, :wrong_type}
end
