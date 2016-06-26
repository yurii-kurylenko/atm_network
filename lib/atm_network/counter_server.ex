defmodule AtmNetwork.CounterServer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :atm_counter)
  end

  def init(_), do: {:ok, 0}

  def remove(value), do: GenServer.cast :atm_counter, {:add, value}
  def current, do: GenServer.call :atm_counter, {:current}

  ###
  def handle_cast({:remove, value}, current), do: {:noreply, current - value}
  def handle_call({:current}, _ , state), do: {:reply, state, state}
end
