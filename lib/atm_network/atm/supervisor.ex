defmodule AtmNetwork.Atm.Supervisor do
  use Supervisor

  def start_link(atm_name) do
    {:ok, sup_pid} = Supervisor.start_link(__MODULE__, nil)
    start_workers(sup_pid, atm_name)
  end

  def start_workers(sup_pid, atm_name) do
    {:ok, state_pid} = Supervisor.start_child(sup_pid, worker(AtmNetwork.Atm.StateServer, []))
    Supervisor.start_child(sup_pid, supervisor(AtmNetwork.Atm.ServerSupervisor, [state_pid, atm_name]))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end
