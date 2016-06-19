defmodule AtmNetwork.CounterServer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :atm_counter)
  end

  def init(_)do
    {:ok, 0}
  end

  def add(value) do
    GenServer.cast :atm_counter, {:add, value}
  end

  def current do
    GenServer.call :atm_counter, {:current}
  end

  def handle_cast({:add, value}, current) do
    {:noreply, current + value}
  end

  def handle_call({:current}, _ , state) do
    {:reply, state, state}
  end

end
# AtmNetwork.Cache.server_process("f1") |> AtmNetwork.Atm.Server.put({1, 2})
