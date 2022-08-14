defmodule Challenge.Validation do
  @moduledoc false

  alias Challenge.Models.{Bet, User, Win}

  import Challenge.Utils, only: [validate_type: 2]

  require Logger

  defdelegate validate_bet(data), to: Bet, as: :new
  defdelegate validate_win(data), to: Win, as: :new
  defdelegate validate_user(user), to: User, as: :new

  @spec validate(map(), list()) :: {:error, any()} | {:ok, map()}
  def validate(params, fields) do
    fields
    |> validate_types(params)
    |> apply_changes()
  end

  defp validate_types([], params), do: {:ok, params}

  defp validate_types([{key, type} | rest], params) do
    params
    |> Map.get(key)
    |> validate_type(type)
    |> case do
      :ok ->
        validate_types(rest, params)

      {:error, :wrong_type} ->
        Logger.debug("#{key} is not #{inspect(type)}")
        {:error, :wrong_type}
    end
  end

  defp apply_changes({:error, :wrong_type}) do
    {:error, :wrong_type}
  end

  defp apply_changes({:ok, params}) do
    {:ok, params |> Map.put(:user, params.supplier_user |> String.trim("hub88_"))}
  end
end
