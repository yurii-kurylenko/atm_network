defmodule AtmNetwork.Atm.StateServer do
  use GenServer

  def start_link() do
    {:ok,_pid} = GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, AtmNetwork.Payload.new}
  end

  def save_payload(pid, value) do
    GenServer.cast pid, {:save_payload, value}
  end

  def get_payload(pid) do
    GenServer.call pid, :get_payload
  end

  def handle_call(:get_payload, _, current_value) do
    {:reply, current_value, current_value}
  end

  def handle_cast({:save_payload, value}, _current_value) do
    {:noreply, value}
  end
end