defmodule AtmNetwork.Atm.State do
  alias AtmNetwork.PayloadList, as: PayloadList
  alias AtmNetwork.Atm.State, as: AtmState
  defstruct payload_list: [], locked: false, last_active: nil, state_pid: nil, subscribers: []

  def new do
    %AtmState{
      payload_list: PayloadList.init_atm_payload_list(),
      locked: false,
      last_active: current_time(),
      state_pid: nil,
      subscribers: []
    }
  end

  def clean_pll(%AtmState{}=state) do
    Map.put(state, :payload_list, PayloadList.init_atm_payload_list())
  end

  def refresh_time(%AtmState{}=state) do
    Map.put(state, :last_active, current_time())
  end

  defp current_time, do: :os.timestamp |> :calendar.now_to_datetime
end
