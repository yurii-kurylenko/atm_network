defmodule AtmNetwork.AtmTest do
  use ExUnit.Case

  test "put cache into atm" do
    AtmNetwork.Atm.clean
    AtmNetwork.Atm.put({1, 1})
    assert AtmNetwork.Atm.current_payload == %AtmNetwork.Payload{
      payload: [{1, 1}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
    }
  end

  test "make cache exchange" do
    IO.puts "start"
    AtmNetwork.Atm.clean
    AtmNetwork.Atm.put({20, 2})
    AtmNetwork.Atm.put({10, 10})
    {exchanged, left} = AtmNetwork.Atm.exchange(120)

    assert exchanged == [{10, 10}, {20, 1}, {100, 0}, {50, 0}, {5, 0}, {2, 0}, {1, 0}]
    assert left == %AtmNetwork.Payload{
      payload: [{1, 0}, {2, 0}, {5, 0}, {10, 0}, {20, 1}, {50, 0}, {100, 0}]
    }
  end
end