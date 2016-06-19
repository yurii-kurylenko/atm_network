defmodule AtmNetwork.Payload do
  @available_values Enum.sort([1, 2, 5, 10, 20, 50, 100])
  defstruct payload: []

  def new(input_payload \\ []) do
    initial_payload = for x <- @available_values, into: [], do: {x, 0}
    add(%AtmNetwork.Payload{payload: initial_payload}, input_payload)
  end

  def add(%AtmNetwork.Payload{payload: payload}, {in_value, in_amount}) do
    response = Enum.map(payload, fn {value, amount} ->
      if value == in_value, do: amount = amount + in_amount
      {value, amount}
    end)
    %AtmNetwork.Payload{payload: response}
  end

  def add(%AtmNetwork.Payload{} = base, [first | other]) do
    base |> add(first) |> add(other)
  end

  def add(%AtmNetwork.Payload{} = base, []) do
    base
  end

  def remove(%AtmNetwork.Payload{payload: payload}, {in_value, in_amount}) do
    response = Enum.map(payload, fn {value, amount} ->
      if value == in_value, do: amount = amount - in_amount
      {value, amount}
    end)
    %AtmNetwork.Payload{payload: response}
  end

  def payload_valid?(%AtmNetwork.Payload{payload: payload}) do
    !Enum.find(payload, false, fn {_ , amount} -> amount < 0 end)
  end

  def exchange(%AtmNetwork.Payload{payload: payload} = base, exchange_amount) do
    payload
      |> count_cache_exchange(exchange_amount, [])
      |> format_answer(base)
  end

  def sum(%AtmNetwork.Payload{payload: payload}) do
    payload |> Enum.reduce(0, fn {value, amount}, acc -> value*amount + acc end)
  end

  defp count_cache_exchange([{value, amount}| tl], exchange_left, acc) do
    k = exchange_left/value
    ceil_amount = k |> Float.ceil |> round
    result_value_amount = if amount >= ceil_amount, do: ceil_amount, else: amount
    acc = acc ++ [{value, result_value_amount}]
    exchange_left = exchange_left - (result_value_amount * value)
    count_cache_exchange(tl, exchange_left, acc)
  end

  defp count_cache_exchange(_, 0, acc) do
    {:ok, acc}
  end

  defp count_cache_exchange([], _, acc) do
    {:error, 'can not make exchange'}
  end

  defp format_answer {:ok, result}, base  do
    {:ok, Enum.reduce(result, base, &remove(&2, &1)), result}
  end

  defp format_answer {:error, reason}, base  do
    {:error, base, reason}
  end
end
