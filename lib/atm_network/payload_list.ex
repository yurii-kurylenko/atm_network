defmodule AtmNetwork.PayloadList do
  alias AtmNetwork.Payload, as: Payload

  def init_atm_payload_list() do
    Payload.available_values
      |> Enum.map(&(%Payload{value: &1, amount: 0} ))
  end

  def join(payloads, [first | others]) do
    payloads |> add(first) |> join(others)
  end

  def join(base, []) do
    base
  end

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


end
