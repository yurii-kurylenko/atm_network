defmodule AtmNetwork.PayloadListTest do
  use ExUnit.Case
  import AtmNetwork.PayloadList
  alias AtmNetwork.Payload, as: Payload

  test "#init_atm_payloads" do
    assert init_atm_payload_list == [
      %Payload{value: 1, amount: 0},
      %Payload{value: 2, amount: 0},
      %Payload{value: 5, amount: 0},
      %Payload{value: 10, amount: 0},
      %Payload{value: 20, amount: 0},
      %Payload{value: 50, amount: 0},
      %Payload{value: 100, amount: 0}
    ]
  end

  test "#add" do
    payloads_list = [%Payload{amount: 1, value: 1}, %Payload{amount: 1, value: 5}]
    payload1 = %Payload{amount: 2, value: 2}
    payload2 = %Payload{amount: 3, value: 1}

    assert add(payloads_list, payload1) == [
      %Payload{value: 1, amount: 1},
      %Payload{value: 5, amount: 1},
      %Payload{value: 2, amount: 2}
    ]

    assert add(payloads_list, payload2) == [
      %Payload{value: 1, amount: 4},
      %Payload{value: 5, amount: 1}
    ]
  end

  test "#join" do
    payload_list1 = [%Payload{amount: 1, value: 1}, %Payload{value: 2, amount: 2}]
    payload_list2 = [%Payload{amount: 1, value: 3}, %Payload{value: 2, amount: 2}]
    assert join(payload_list1, payload_list2) == [
      %Payload{amount: 1, value: 1},
      %Payload{amount: 4, value: 2},
      %Payload{amount: 1, value: 3}
    ]
  end
  #
  # test "#remove valid" do
  #   result_payload = new([%{value: 1, amount: 2}]) |> remove([%{value: 1, amount: 1}])
  #   assert result_payload == %AtmNetwork.Payload{
  #     payload: [
  #       %{value: 1, amount: 1}, %{value: 2, amount: 0},
  #       %{value: 5, amount: 0}, %{value: 10, amount: 0},
  #       %{value: 20, amount: 0}, %{value: 50, amount: 0},
  #       %{value: 100, amount: 0}
  #     ]
  #   }
  # end
  #
  # test "#not valid payload" do
  #   result_payload = new([]) |> remove([%{amount: 1, value: 1}])
  #   assert payload_valid?(result_payload) == false
  # end
  # #
  # test "valid payload" do
  #   result_payload = new([%{amount: 1, value: 1}]) |> remove([%{amount: 1, value: 1}])
  #   assert payload_valid?(result_payload) == true
  # end
  #
  # test "exchange success" do
  #    {:ok, left, exchanged} = new([%{value: 1, amount: 5}]) |> exchange(2)
  #   #  assert exchanged == [{1, 2}, {2, 0}, {5, 0}, {10, 0}, {20, 0}, {50, 0}, {100, 0}]
  #    assert left ==  %AtmNetwork.Payload{
  #      payload: [
  #        %{value: 1, amount: 3}, %{value: 2, amount: 0},
  #        %{value: 5, amount: 0}, %{value: 10, amount: 0},
  #        %{value: 20, amount: 0}, %{value: 50, amount: 0},
  #        %{value: 100, amount: 0}
  #      ]
  #    }
  # end
  #
  # test "exchange faild" do
  #    {:error, _ , reason} = new([{1, 5}]) |> exchange(10)
  #    assert reason == 'can not make exchange'
  # end
  #
  # test "sum" do
  #   sum = new([{1, 5}, {10, 2}, {20, 3}]) |> sum
  #   assert sum == 85
  # end
end
