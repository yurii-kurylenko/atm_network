defmodule AtmNetwork.RootSupervisor do
  use Supervisor

  def start_link do
    IO.puts "starting RootSupervisor"
    Supervisor.start_link(__MODULE__, nil, name: :root_atm_supervisor)
  end

  def init(_) do
    processes = [
      supervisor(AtmNetwork.Atm.AtmsPoolSupervisor, []),
      worker(AtmNetwork.Cache, [])
    ]

    supervise(processes, strategy: :one_for_one)
  end
end