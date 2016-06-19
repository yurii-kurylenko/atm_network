defmodule AtmNetwork.PayloadTest do
  use ExUnit.Case
  import AtmNetwork.Payload

  test "#new" do
    assert new == %AtmNetwork.Payload{
      payload: [{1, 0}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
    }
    assert new([{1, 2}, {2, 3}]) == %AtmNetwork.Payload{
      payload: [{1, 2}, {2, 3}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
    }
  end

  test "#add" do
    cache_payload = new |> add({1, 2})
    assert cache_payload == %AtmNetwork.Payload{
      payload: [{1, 2}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
    }
  end

  test "#remove valid" do
    result_payload = new([{1, 2}]) |> remove({1, 1})
    assert result_payload == %AtmNetwork.Payload{
      payload: [{1, 1}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
    }
  end

  test "#not valid payload" do
    result_payload = new([]) |> remove({1, 1})
    assert payload_valid?(result_payload) == false
  end

  test "valid payload" do
    result_payload = new([{1, 5}]) |> remove({1, 1})
    assert payload_valid?(result_payload) == true
  end

  test "exchange success" do
     {:ok, left, exchanged} = new([{1, 5}]) |> exchange(2)
     assert exchanged == [{1, 2}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
     assert left == %AtmNetwork.Payload{payload: [{1, 3}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]}
  end

  test "exchange faild" do
     {:error, _ , reason} = new([{1, 5}]) |> exchange(10)
     assert reason == 'can not make exchange'
  end

  test "sum" do
    sum = new([{1, 5}, {10, 2}, {20, 3}]) |> sum
    assert sum == 85
  end
end
