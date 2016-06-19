defmodule AtmNetwork.Atm.Server do
  use GenServer
  alias AtmNetwork.Payload, as: Payload

  def start_link(state_pid, name) do
    GenServer.start_link(__MODULE__, state_pid, name: via_tuple(name))
  end

  def init(state_pid) do
    payload = AtmNetwork.Atm.StateServer.get_payload(state_pid)
    {:ok, {payload, state_pid, false}}
  end

  def current_payload(atm) do
    GenServer.call(atm, {:current_payload})
  end

  def put(atm, {_, _} = cache) do
    GenServer.cast(atm, {:put, cache})
  end

  def exchange(atm, amount) do
    GenServer.call(atm, {:exchange, amount})
  end

  def clean(atm) do
    GenServer.cast(atm, {:clean})
  end

  def toggle_lock(atm) do
    GenServer.call(atm, {:toggle_lock})
  end

  defp via_tuple(name) do
    {:via, :gproc, {:n, :l, {:atm, name}}}
  end

  def whereis(name) do
    :gproc.whereis_name({:n, :l, {:atm, name}})
  end

  def shutdown(atm) do
    GenServer.cast(atm, {:shutdown})
  end
  ###

  def handle_call({:current_payload}, _, {payload, _, _} = state) do
    {
      :reply,
      payload,
      state
    }
  end

  def handle_call({:exchange, amount}, _, {payload, state_pid, locked} = state) when locked == false do
    case Payload.exchange(payload, amount) do
      {:ok, left, exchanged} ->
        AtmNetwork.Atm.StateServer.save_payload(state_pid, left)
        {:reply, {:ok, {exchanged, left} }, {left, state_pid, locked}}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:exchange, _}, _, {_, _, locked} = state) when locked == true do
    {:reply, {:error, "Atm is locked"}, state}
  end

  def handle_cast({:put, cache}, {payload, state_pid, locked}) when locked == false do
    new_payload = Payload.add(payload, cache)
    AtmNetwork.Atm.StateServer.save_payload(state_pid, new_payload)
    {
      :noreply,
      {new_payload, state_pid, locked}
    }
  end

  def handle_cast({:put, _}, {_, _, locked} = state) when locked == true do
    {
      :noreply,
      state
    }
  end

  def handle_cast({:clean}, {_, state_pid, locked}) when locked == false do
    AtmNetwork.Atm.StateServer.save_payload(state_pid, Payload.new)
    {
      :noreply,
      {Payload.new, state_pid, locked}
    }
  end

  def handle_cast({:clean}, {_, _, locked} = state) when locked == true do
    {
      :noreply,
      state
    }
  end

  def handle_cast({:shutdown}, state) do
    {:stop, :normal, state}
  end

  def handle_call({:toggle_lock}, _, {payload, state_pid, locked}) do
    {:reply, {:ok, !locked}, {payload, state_pid, !locked}}
  end

  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}

end
