defmodule AtmNetwork.Payload do
  alias AtmNetwork.Payload, as: Payload

  @available_values [1, 2, 5, 10, 20, 50, 100]
  defstruct value: nil, amount: nil

  def new(%{value: value, amount: amount} = base) when is_integer(amount) and value in @available_values do
    struct(Payload, base)
  end

  def add(%Payload{} = v1, %Payload{} = v2) do
    if v1.value == v2.value do
      {:ok, Map.put(v1, :amount, v1.amount + v2.amount)}
    else
      {:error, 'different payload value'}
    end
  end

  def remove(%Payload{} = v1, %Payload{} = v2) do
    v2 = Map.put(v2, :amount, -1 * v2.amount)
    add(v1, v2)
  end

  def available_values do
    @available_values
  end
end
