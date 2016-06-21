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
      {:error, v1}
    end
  end

  def remove(%Payload{} = v1, %Payload{} = v2) do
    Map.put(v2, :amount, -1 * v2.amount)
    add(v1, v2)
  end

  def available_values do
    @available_values
  end

  #
  # def remove(%AtmNetwork.Payload{} = base, [_ | _] = input_array) do
  #   converted_array = Enum.map(input_array, &(Map.put(&1, :amount, &1.amount * -1)))
  #   base |> add(hd(converted_array)) |> add(tl(converted_array))
  # end
  #
  # def payload_valid?(%AtmNetwork.Payload{payload: payload}) do
  #   !Enum.find(payload, false, fn %{value: _, amount: amount} -> amount < 0 end)
  # end
  #
  # def exchange(%AtmNetwork.Payload{payload: payload} = base, exchange_amount) do
  #   payload
  #     |> count_cache_exchange(exchange_amount, [])
  #     |> format_answer(base)
  # end
  #
  # def sum(%AtmNetwork.Payload{payload: payload}) do
  #   payload |> Enum.reduce(0, fn {value, amount}, acc -> value*amount + acc end)
  # end
  #
  # defp count_cache_exchange([%{value: value, amount: amount}| tl], exchange_left, acc) do
  #   k = exchange_left/value
  #   ceil_amount = k |> Float.ceil |> round
  #   result_value_amount = if amount >= ceil_amount, do: ceil_amount, else: amount
  #   acc = acc ++ [%{value: value, amount: result_value_amount}]
  #   exchange_left = exchange_left - (result_value_amount * value)
  #   count_cache_exchange(tl, exchange_left, acc)
  # end
  #
  # defp count_cache_exchange(_, 0, acc) do
  #   {:ok, acc}
  # end
  #
  # defp count_cache_e  xchange([], _, acc) do
  #   {:error, 'can not make exchange'}
  # end
  #
  # defp format_answer {:ok, result}, base  do
  #   {:ok, Enum.reduce(result, base, &remove(&2, &1)), result}
  # end
  #
  # defp format_answer {:error, reason}, base  do
  #   {:error, base, reason}
  # end
end
