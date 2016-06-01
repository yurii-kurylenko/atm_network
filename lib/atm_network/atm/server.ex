defmodule AtmNetwork.Atm.Server do
  use GenServer

  def start_link(state_pid, name) do
    IO.puts "starting #{name}"
    GenServer.start_link(__MODULE__, [state_pid, name], name: via_tuple(name))
  end

  def init(state_pid, name) do
    payload = AtmNetwork.AtmStateServer.get_payload(state_pid)
    {:ok, {payload, state_pid}}
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

  def handle_call({:current_payload}, _, {payload, state_pid} = state) do
    {
      :reply,
      payload,
      state
    }
  end

  def handle_call({:exchange, amount}, _, {payload, state_pid} = state) do
    case AtmNetwork.Payload.exchange(payload, amount) do
      {:ok, left, exchanged} ->
        AtmNetwork.AtmStateServer.save_payload(state_pid, left)
        {:reply, {exchanged, left}, {left, state_pid}}
      {:error, reason} ->
        {:reply, reason, state}
    end
  end

  def handle_cast({:put, cache}, {payload, state_pid} = state) do
    new_payload = AtmNetwork.Payload.add(payload, cache)
    AtmNetwork.AtmStateServer.save_payload(state_pid, new_payload)
    {
      :noreply,
      {new_payload, state_pid}
    }
  end

  def handle_cast({:clean}, {payload, state_pid} = state) do
    AtmNetwork.Atm.StateServer.save_payload(state_pid, AtmNetwork.Payload.new)
    {
      :noreply,
      AtmNetwork.Payload.new
    }
  end

  def handle_cast({:shutdown}, state) do
    {:stop, :normal, state}
  end

  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}

end

# AtmNetwork.Server.start
# AtmNetwork.Server.put({1, 1})
# AtmNetwork.Server.current_payload
