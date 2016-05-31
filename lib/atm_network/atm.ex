defmodule AtmNetwork.Atm do
  use GenServer

  def start_link do
    IO.puts "starting"
    GenServer.start_link(__MODULE__, nil, name: :cache_box)
  end

  def init(_) do
    {:ok, AtmNetwork.Payload.new}
  end

  def current_payload do
    GenServer.call(:cache_box, {:current_payload})
  end

  def put({_, _} = cache) do
    GenServer.cast(:cache_box, {:put, cache})
  end

  def exchange(amount) do
    GenServer.call(:cache_box, {:exchange, amount})
  end

  def shutdown do
    send(:cache_box, :stop)
  end

  def clean do
    GenServer.cast(:cache_box, {:clean})
  end

  def handle_call({:current_payload}, _, payload) do
    {
      :reply,
      payload,
      payload
    }
  end

  def handle_call({:exchange, amount}, _, payload) do
    case AtmNetwork.Payload.exchange(payload, amount) do
      {:ok, left, exchanged} ->
        {:reply, { exchanged, left}, left }
      {:error, reason} ->
        {:reply, reason, payload}
    end
  end

  def handle_cast({:put, cache}, payload) do
    {
      :noreply,
      AtmNetwork.Payload.add(payload, cache)
    }
  end

  def handle_cast({:clean}, _) do
    {
      :noreply,
      AtmNetwork.Payload.new
    }
  end


  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}

end

# AtmNetwork.Server.start
# AtmNetwork.Server.put({1, 1})
# AtmNetwork.Server.current_payload