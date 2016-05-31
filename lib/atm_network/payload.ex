defmodule AtmNetwork.Payload do
  @available_values Enum.sort([1, 2, 5, 10, 20, 50, 100])
  defstruct payload: []

  def new(input_payload \\ []) do
    initial_payload = for x <- @available_values, into: [], do: {x, 0}
    Enum.reduce(
      input_payload,
      %AtmNetwork.Payload{payload: initial_payload},
      &add(&2, &1)
    )
  end

  def add(%AtmNetwork.Payload{payload: payload}, {in_value, in_amount}) do
    response = Enum.map(payload, fn {value, amount} ->
      if value == in_value, do: amount = amount + in_amount
      {value, amount}
    end)
    %AtmNetwork.Payload{payload: response}
  end

  def remove(%AtmNetwork.Payload{payload: payload}, {in_value, in_amount}) do
    response = Enum.map(payload, fn {value, amount} ->
      if value == in_value, do: amount = amount - in_amount
      {value, amount}
    end)
    %AtmNetwork.Payload{payload: response}
  end

  def payload_valid?(%AtmNetwork.Payload{payload: payload}) do
    !Enum.find(payload, false, fn { _ , amount} -> amount < 0 end)
  end

  def exchange(%AtmNetwork.Payload{payload: payload} = base, exchange_amount) do
    payload
      |> calc_value_factor
      |> count_cache_exchange(exchange_amount)
      |> format_answer(base)
  end

  #### Private

  def calc_value_factor(payload) do
    total_cache = payload |> Stream.map(fn {value, amount} -> value * amount end) |> Enum.sum
    payload |> Stream.map(fn {value, amount} -> {value, amount, (value*amount*amount)/total_cache} end)
      |> Enum.sort(fn {_,_,k1}, {_,_,k2}  -> k1 > k2 end)
  end

  defp count_cache_exchange([{value, amount, _}| tl], exchange_left, acc \\ []) do
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