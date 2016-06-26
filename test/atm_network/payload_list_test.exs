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

  test "#remove success" do
    payload_list1 = [%Payload{amount: 1, value: 1}, %Payload{amount: 2, value: 2}]
    payload_list2 = [%Payload{amount: 1, value: 1}, %Payload{value: 2, amount: 1}]

    assert remove(payload_list1, payload_list2) == {:ok, [
      %Payload{value: 1, amount: 0},
      %Payload{value: 2, amount: 1}
    ]}
  end

  test "#remove failed" do
    payload_list1 = [%Payload{amount: 1, value: 1}, %Payload{amount: 2, value: 2}]
    payload_list2 = [%Payload{amount: 4, value: 1}, %Payload{value: 3, amount: 1}]

    assert remove(payload_list1, payload_list2) == {:error, payload_list1}
  end


  test "exchange success" do
     {:ok, left, result} = [%Payload{value: 1, amount: 5}] |> exchange(2)

     assert left == [
       %Payload{value: 1, amount: 3}
     ]
     assert result == [%Payload{value: 1, amount: 2}]
  end

  test "exchange faild" do
     {:error, _, reason} = [%Payload{value: 1, amount: 5}] |> exchange(10)
     assert reason == 'can not make exchange'
  end

  test "sum" do
    sum = [%Payload{value: 1, amount: 5}, %Payload{value: 50, amount: 20}] |> sum
    assert sum == 1005
  end
end
