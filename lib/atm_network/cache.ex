defmodule AtmNetwork.Cache do
  use GenServer

  def start_link do
    IO.puts "Starting atms cache."

    GenServer.start_link(__MODULE__, nil, name: :atms_cache)
  end

  def server_process(atm_name) do
    case AtmNetwork.Atm.Server.whereis(atm_name) do
      :undefined ->
        GenServer.call(:atms_cache, {:server_process, atm_name})
      pid -> pid
    end
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:server_process, atm_name}, _, state) do
    atm_pid = case AtmNetwork.Atm.Server.whereis(atm_name) do
      :undefined ->
        {:ok, _} = AtmNetwork.Atm.AtmsPoolSupervisor.start_child(atm_name)
        AtmNetwork.Atm.Server.whereis(atm_name)
      pid -> pid
    end
    {:reply, atm_pid, state}
  end
end
