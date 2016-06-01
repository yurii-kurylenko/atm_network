defmodule AtmNetwork.Application do
  use Application

  def start(_,_) do
    AtmNetwork.RootSupervisor.start_link
  end
end