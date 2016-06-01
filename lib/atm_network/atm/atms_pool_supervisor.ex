defmodule AtmNetwork.Atm.AtmsPoolSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: :atms_pool_supervisor)
  end

  def start_child(atm_name) do
    Supervisor.start_child(:atms_pool_supervisor, [atm_name])
  end

  def init(_) do
    supervise([supervisor(AtmNetwork.Atm.Supervisor, [])], strategy: :simple_one_for_one)
  end
end