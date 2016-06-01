defmodule AtmNetwork.Atm.ServerSupervisor do
  use Supervisor

  def start_link(state_pid, atm_name) do
    IO.puts "Starting atm server! supervisor"
    Supervisor.start_link(__MODULE__, {state_pid, atm_name})
  end

  def init {state_pid, atm_name} do
    supervise [worker(AtmNetwork.Atm.Server, [state_pid, atm_name])], strategy: :one_for_one
  end
end