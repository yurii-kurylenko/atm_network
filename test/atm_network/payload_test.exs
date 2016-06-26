defmodule AtmNetwork.PayloadTest do
  use ExUnit.Case
  import AtmNetwork.Payload
  alias AtmNetwork.Payload, as: Payload

  test "#new" do
    assert new(%{amount: 1, value: 1}) == %Payload{value: 1, amount: 1  }
  end

  test "#add" do
    v1 = %Payload{value: 1, amount: 1 }
    v2 = %Payload{value: 2, amount: 1 }

    assert add(v1, v1) == {:ok, %Payload{value: 1, amount: 2} }
    assert add(v1, v2) == {:error, 'different payload value'}

  end

  test "#remove" do
    v1 = %Payload{value: 2, amount: 5 }
    v2 = %Payload{value: 2, amount: 2 }
    v3 = %Payload{value: 4, amount: 2 }

    assert remove(v1, v2) == {:ok, %Payload{value: 2, amount: 3} }
    assert remove(v2, v1) == {:ok, %Payload{value: 2, amount: -3} }
    assert remove(v1, v3) == {:error, 'different payload value'}
  end


end
