defmodule AtmNetwork.Cache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :atms_cache)
  end

  def server_process(atm_name) do
    case AtmNetwork.Atm.Server.whereis(atm_name) do
      :undefined ->
        GenServer.call(:atms_cache, {:server_process, atm_name})
      pid -> pid
    end
  end

  def all do
    # TODO: Do more accurate select
    registered_processes = :gproc.select({:all, :all}, [{:_, [], [:"$$"]}])
    for [{:n, :l,{:atm, name}}, pid, _] <- registered_processes, into: [] do
      {name, pid}
    end
  end

  def init(_), do: {:ok, nil}

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
