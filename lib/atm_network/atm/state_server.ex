defmodule AtmNetwork.Atm.StateServer do
  use GenServer
  alias AtmNetwork.Payload, as: Payload

  def start_link() do
    {:ok,_pid} = GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, Payload.new}
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

  def handle_cast({:save_payload, value}, current) do
    [current, value]
      |> Enum.map(&(Payload.sum(&1)))
      |> Enum.reduce(&-/2)
      |> AtmNetwork.CounterServer.add
    {:noreply, value}
  end
end
