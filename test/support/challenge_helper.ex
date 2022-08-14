defmodule Test.Support.ChallengeHelper do
  @moduledoc false

  @bet_data %{
    supplier_user: "hub88_john12345",
    transaction_uuid: "16d2dcfe-b89e-11e7-854a-58404eea6d16",
    token: "55b7518e-b89e-11e7-81be-58404eea6d16",
    round_closed: false,
    round: "rNEMwgzJAOZ6eR3V",
    reward_uuid: "a28f93f2-98c5-41f7-8fbb-967985acf8fe",
    request_uuid: "583c985f-fee6-4c0e-bbf5-308aad6265af",
    is_free: true,
    game_id: 132,
    game_code: "clt_dragonrising",
    currency: "USD",
    bet: "zero",
    amount: 10_500,
    meta: %{
      selection: "home_team",
      odds: 2.5
    }
  }

  @win_data %{
    supplier_user: "hub88_john12345",
    transaction_uuid: "15d2dcfe-b89e-11e7-854a-58404eea6d16",
    token: "55b7518e-b89e-11e7-81be-58404eea6d16",
    round_closed: true,
    round: "rNEMwgzJAOZ6eR3V",
    reward_uuid: "a28f93f2-98c5-41f7-8fbb-967985acf8fe",
    request_uuid: "412c985f-fee6-4c0e-bbf5-308aad6265af",
    reference_transaction_uuid: "16d2dcfe-b89e-11e7-854a-58404eea6d16",
    is_free: true,
    game_id: 132,
    game_code: "clt_dragonrising",
    currency: "USD",
    bet: "zero",
    amount: 10_500,
    meta: %{
      selection: "home_team",
      odds: 2.5
    }
  }

  def bet_data, do: @bet_data
  def win_data, do: @win_data

  def update(data, params) do
    Map.merge(data, params)
  end
end
