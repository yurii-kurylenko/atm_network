defmodule AtmNetwork.Atm.Server do
  use GenServer
  alias AtmNetwork.PayloadList, as: PayloadList
  alias AtmNetwork.Atm.State, as: AtmState
  alias AtmNetwork.Atm.StateServer, as: StateServer

  def start_link(state_pid, name) do
    GenServer.start_link(__MODULE__, state_pid, name: via_tuple(name))
  end

  def init(state_pid), do: {:ok, StateServer.get_state(state_pid)}
  ###

  def put(atm, pll), do: GenServer.call(atm, {:put, pll})
  def clean(atm), do: GenServer.call(atm, {:clean})
  def shutdown(atm), do: GenServer.cast(atm, {:shutdown})

  def current_payload(atm),  do: GenServer.call(atm, {:current_payload})
  def exchange(atm, amount),  do: GenServer.call(atm, {:exchange, amount})
  def toggle_lock(atm), do: GenServer.call(atm, {:toggle_lock})

  def whereis(name), do: :gproc.whereis_name({:n, :l, {:atm, name}})

  ###

  def handle_call({:current_payload}, _, %AtmState{}=state) do
    {:reply, state.payload_list, state}
  end

  def handle_call({:toggle_lock}, _, {payload, state_pid, locked}) do
    {:reply, {:ok, !locked}, {payload, state_pid, !locked}}
  end

  def handle_call({:exchange, amount}, _, %AtmState{locked: locked}=state) when locked == false do
    case PayloadList.exchange(state.payload_list, amount) do
      {:ok, left, exchanged} ->
        new_state = Map.put(state, :payload_list, left)
        StateServer.save(new_state)
        {:reply, {:ok, exchanged, left}, new_state}
      {:error, _, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:exchange, _}, _, %AtmState{locked: locked}=state) when locked == true do
    {:reply, {:error, "Atm is locked"}, state}
  end

  def handle_call({:put, pll}, _, %AtmState{locked: locked}=state) when locked == false do
    new_pll = state.payload_list |> PayloadList.join  (pll)
    new_state = state
      |> Map.put(:payload_list, new_pll)
      |> AtmState.refresh_time
    {:ok, _} = StateServer.save(new_state)
    {:reply, {:ok, new_pll}, new_state}
  end

  def handle_call({:put, _}, _, %AtmState{locked: locked}=state) when locked == true do
    {:reply, {:error, 'Atm is locked!'}, state}
  end

  def handle_call({:clean}, _,  %AtmState{locked: locked}=state) when locked == false do
    new_state = AtmState.clean_pll(state) |> AtmState.refresh_time
    StateServer.save(new_state)
    {:reply, {:ok, new_state.payload_list}, new_state}
  end

  def handle_call({:clean}, _, %AtmState{locked: locked}=state) when locked == true do
    {:reply, {:error, 'Atm is locked'}, state}
  end

  def handle_cast({:shutdown}, state),  do:     {:stop, :normal, state}


  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}

  ###
  defp via_tuple(name), do: {:via, :gproc, {:n, :l, {:atm, name}}}
end
