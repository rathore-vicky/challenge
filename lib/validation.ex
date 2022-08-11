defmodule Challenge.Validation do
  @moduledoc false

  alias Challenge.Validation.Bet
  alias Challenge.Validation.Win

  require Logger

  def validate_user(user_name) do
    validate_type(user_name, :binary)
  end

  defdelegate validate_bet(data), to: Bet, as: :validate
  defdelegate validate_win(data), to: Win, as: :validate

  def validate_params([], params, _required_fields) do
    {:ok, params |> Map.put(:user, params.supplier_user |> String.trim("hub88_"))}
  end

  def validate_params([{key, value} | rest], params, required_fields) do
    pkey = Map.get(params, key)

    case validate_type(pkey, value) do
      :ok ->
        validate_params(rest, params, required_fields)

      {:error, _error} ->
        if is_nil(pkey) and key in required_fields do
          Logger.debug("#{key} is required")
          {:error, :is_required}
        else
          Logger.debug("#{key} is not #{value}")
          {:error, :invalid_type}
        end
    end
  end

  defp validate_type(value, :boolean) when is_boolean(value), do: :ok
  defp validate_type(value, :integer) when is_integer(value), do: :ok
  defp validate_type(value, :float) when is_float(value), do: :ok
  defp validate_type(value, :number) when is_number(value), do: :ok
  defp validate_type(value, :string) when is_binary(value), do: :ok
  defp validate_type(value, :binary) when is_binary(value), do: :ok
  defp validate_type(value, :atom) when is_atom(value), do: :ok
  defp validate_type(value, :map) when is_map(value), do: :ok

  # we will add some more validation here
  defp validate_type(_, _type), do: {:error, :invalid_type}
end
