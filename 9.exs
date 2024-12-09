defmodule Aoc9 do
  def example() do
    "2333133121414131402"
  end

  def part_one(input) do
    input
    |> parse_input()
    |> Enum.chunk_every(2, 2, [0])
    |> Enum.with_index()
    |> Enum.flat_map(fn {[taken, free], i} -> repeat(i, taken) ++ repeat(:x, free) end)
    |> List.to_tuple()
    |> compress()
  end

  def part_two(input) do
    input
    |> parse_input()
    |> Enum.chunk_every(2, 2, [0])
    |> Enum.with_index()
    |> compress_whole()
    |> Enum.reduce({0, 0}, &get_checksum/2)
    |> elem(1)
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("9.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
  end

  defp repeat(value, n), do: Tuple.duplicate(value, n) |> Tuple.to_list()

  defp compress(memory), do: compress(memory, 0, tuple_size(memory) - 1, 0)
  defp compress(_, pleft, pright, sum) when pleft > pright, do: sum
  defp compress(memory, pleft, pright, sum) do
    left = elem(memory, pleft)
    right = elem(memory, pright)
    cond do
      left != :x -> compress(memory, pleft + 1, pright, sum + pleft * left)
      right == :x -> compress(memory, pleft, pright - 1, sum)
      true -> compress(memory, pleft + 1, pright - 1, sum + pleft * right)
    end
  end

  defp compress_whole(chunks), do: compress_whole(chunks, length(chunks) - 1)
  defp compress_whole(chunks, 0), do: chunks
  defp compress_whole(chunks, ix) do
    {first_half, target, second_half} = partition(chunks, ix)
    {[size, free], _} = target

    case fit_in(first_half, size, ix, []) do
      {:not_found, _} -> chunks
      {:ok, result} -> increase_free(result, free + size) ++ second_half
    end
    |> compress_whole(ix - 1)
  end

  defp partition(chunks, ix, acc \\ [])
  defp partition([], _ix, acc), do: {acc, nil, nil}
  defp partition([{_, el_ix} = el | rest], ix, acc) when el_ix == ix do
    {Enum.reverse(acc), el, rest}
  end
  defp partition([el | rest], ix, acc), do: partition(rest, ix, [el | acc])

  defp get_checksum({[taken, free], el_ix}, {ix, sum}) do
    {ix + taken + free, sum + el_ix * div((ix + ix + taken - 1) * taken, 2)}
  end

  defp increase_free(chunks, free) do
    [{[size, old_free], ix} | rest] = Enum.reverse(chunks)
    [{[size, old_free + free], ix} | rest] |> Enum.reverse()
  end

  defp fit_in(chunks, size, ix, acc)
  defp fit_in([], _, _, acc), do: {:not_found, Enum.reverse(acc)}
  defp fit_in([el | rest], size, ix, acc) do
    {[el_size, free], el_ix} = el
    if free >= size do
      rest = [{[el_size, 0], el_ix}, {[size, free - size], ix} | rest]
      {:ok, Enum.reverse(acc) ++ rest}
    else
      fit_in(rest, size, ix, [el | acc])
    end
  end
end
