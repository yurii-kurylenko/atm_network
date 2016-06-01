defmodule AtmNetwork.PayloadTest do
  use ExUnit.Case

  test "#new" do
    assert AtmNetwork.Payload.new == %AtmNetwork.Payload{
      payload: [{1, 0}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
    }
    assert AtmNetwork.Payload.new([{1, 2}]) == %AtmNetwork.Payload{
      payload: [{1, 2}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
    }
  end

  test "#add" do
    cache_payload = AtmNetwork.Payload.new |> AtmNetwork.Payload.add({1, 2})
    assert cache_payload == %AtmNetwork.Payload{
      payload: [{1, 2}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
    }
  end

  test "#remove valid" do
    result_payload = AtmNetwork.Payload.new([{1, 2}]) |> AtmNetwork.Payload.remove({1, 1})
    assert result_payload == %AtmNetwork.Payload{
      payload: [{1, 1}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
    }
  end

  test "#not valid payload" do
    result_payload = AtmNetwork.Payload.new([]) |> AtmNetwork.Payload.remove({1, 1})
    assert AtmNetwork.Payload.payload_valid?(result_payload) == false
  end

  test "valid payload" do
    result_payload = AtmNetwork.Payload.new([{1, 5}]) |> AtmNetwork.Payload.remove({1, 1})
    assert AtmNetwork.Payload.payload_valid?(result_payload) == true
  end

  test "exchange success" do
     {:ok, left, exchanged} = AtmNetwork.Payload.new([{1, 5}]) |> AtmNetwork.Payload.exchange(2)
     assert exchanged == [{1, 2}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
     assert left == %AtmNetwork.Payload{payload: [{1, 3}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]}
  end

  test "exchange faild" do
     {:error, _ , reason} = AtmNetwork.Payload.new([{1, 5}]) |> AtmNetwork.Payload.exchange(10)
     assert reason == 'can not make exchange'
  end
end
