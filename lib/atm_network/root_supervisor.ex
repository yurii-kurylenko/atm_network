defmodule AtmNetwork.RootSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: :root_atm_supervisor)
  end

  def init(_) do
    processes = [
      supervisor(AtmNetwork.Atm.AtmsPoolSupervisor, []),
      worker(AtmNetwork.Cache, []),
      worker(AtmNetwork.CounterServer, [])
    ]

    supervise(processes, strategy: :one_for_one)
  end
end
