defmodule AtmNetwork.Atm.ServerTest do
  use ExUnit.Case
  alias AtmNetwork.Atm.Server, as: Server
  alias AtmNetwork.Atm.StateServer, as: StateServer
  alias AtmNetwork.Payload, as: Payload

  # TODO: refactoring
  test "#all" do
    {_, st} = AtmNetwork.Atm.StateServer.start_link()
    {_, sr} = AtmNetwork.Atm.Server.start_link(st, "11")
    {:ok, new_pll} = Server.put(sr, [%Payload{amount: 1, value: 10}, %Payload{amount: 10, value: 5}])

    assert Enum.member?(new_pll, %Payload{amount: 1, value: 10}) == true
    assert StateServer.get_state(st).payload_list == new_pll
    assert Server.current_payload(sr) == new_pll

    {:ok, exchanged, left} = Server.exchange(sr, 10)
    assert Enum.member?(exchanged, %Payload{amount: 2, value: 5}) == true
    assert Enum.member?(left, %Payload{amount: 8, value: 5}) == true
  end

end
