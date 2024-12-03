defmodule Aoc1 do
  def example() do
    """
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    """
  end

  def part_1(input_str) do
    input_str
    |> to_two_lists()
    |> Tuple.to_list()
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip_reduce(0, fn [left, right], acc -> acc + abs(left - right) end)
  end

  def part_2(input_str) do
    input_str
    |> to_two_lists()
    |> Tuple.to_list()
    |> Enum.map(&Enum.frequencies/1)
    |> get_similarity()
  end

  def get_result(part \\ 1) do
    inputs = Aoc.Common.read_inputs("1.txt")
    case part do
      1 -> part_1(inputs)
      2 -> part_2(inputs)
    end
  end

  defp to_two_lists(input_str) do
    input_str
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(
      fn line -> 
        line 
        |> String.split() 
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end
    )
    |> Enum.unzip()
  end

  defp get_similarity([lhs_freqs, rhs_freqs]) do
    lhs_freqs
    |> Map.to_list()
    |> Enum.map(fn {el, fr} -> el * fr * Map.get(rhs_freqs, el, 0) end)
    |> Enum.sum()
  end
end
