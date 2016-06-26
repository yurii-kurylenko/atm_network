defmodule AtmNetwork.PayloadList do
  alias AtmNetwork.Payload, as: Payload

  def init_atm_payload_list() do
    Payload.available_values
      |> Enum.map(&(%Payload{value: &1, amount: 0} ))
  end

  def join(payloads, [first | others]) do
    payloads |> add(first) |> join(others)
  end

  def join(base, []), do: base

  def add(base_payload_list, new_payload) do
    add(base_payload_list, new_payload, [])
  end

  def add([hd | tl], %Payload{} = new_payload, acc) do
    case Payload.add(hd, new_payload) do
      {:ok, result} ->
        acc ++ [result | tl]
      {:error, _} ->
        add(tl, new_payload, acc ++ [hd])
    end
  end

  def add([], %Payload{} = new_payload, acc) do
    acc ++ [new_payload]
  end

  def remove(payload_list, list_to_remove) do
    converted_list_to_remove = Enum.map(list_to_remove, &(Map.put(&1, :amount, &1.amount * -1)))
    result = join(payload_list, converted_list_to_remove)
    if payload_list_valid?(result) do
      {:ok, result}
    else
      {:error, payload_list}
    end
  end

  def exchange(payload_list, exchange_amount) do
    payload_list
      |> count_cache_exchange(exchange_amount, [])
      |> format_answer(payload_list)
  end

  def sum(payload_list) do
    payload_list |> Enum.reduce(0, &(&1.value*&1.amount + &2))
  end

  defp payload_list_valid?(payload_list) do
    !Enum.find(payload_list, false, &(&1.amount < 0))
  end

  defp count_cache_exchange([hd | tl], exchange_left, acc) do
    k = exchange_left/hd.value
    ceil_amount = k |> Float.ceil |> round
    result_value_amount = if hd.amount >= ceil_amount, do: ceil_amount, else: hd.amount
    acc = acc ++ [%Payload{value: hd.value, amount: result_value_amount}]
    exchange_left = exchange_left - (result_value_amount * hd.value)
    count_cache_exchange(tl, exchange_left, acc)
  end

  defp count_cache_exchange(_, 0, acc) do
    {:ok, acc}
  end

  defp count_cache_exchange([], _, _) do
    {:error, 'can not make exchange'}
  end

  defp format_answer {:ok, result}, initial_pl  do
    {:ok, left } = remove(initial_pl, result)
    {:ok, left, result}
  end

  defp format_answer {:error, reason}, initial_pl  do
    {:error, initial_pl, reason}
  end

end
