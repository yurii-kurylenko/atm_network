defmodule AtmNetwork.Atm.StateServer do
  use GenServer
  alias AtmNetwork.Atm.State, as: AtmState

  def start_link(), do: {:ok,_pid} = GenServer.start_link(__MODULE__, nil)

  def init(_) do
    initial_atm_state = Map.put(AtmState.new, :state_pid, self)
    {:ok, initial_atm_state}
  end

  def save(%AtmState{}=state), do: GenServer.call state.state_pid, {:save, state}
  def get_state(pid), do: GenServer.call pid, {:get_state}
  def clean(%AtmState{}=state), do: GenServer.call state.state_pid, :clean

  ###

  def handle_call({:get_state}, _, state), do: {:reply, state, state}

  def handle_call({:save, new_state}, _, _) do
    {:reply, {:ok, new_state}, new_state}
  end

end
