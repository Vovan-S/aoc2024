defmodule Aoc2 do
  def example() do
    """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    """
  end

  def part_one(input_str) do
    input_str
    |> parse_input()
    |> Enum.count(&is_safe?/1)
  end

  def part_two(input_str) do
    input_str
    |> parse_input()
    |> Enum.count(&is_safish?/1)
  end

  def get_result(part \\ 1) do
    inputs = Aoc.Common.read_inputs("2.txt")
    case part do
      1 -> part_one(inputs)
      2 -> part_two(inputs)
    end
  end

  defp is_safe?(seq) do
    diffs = seq
    |> Enum.zip(Enum.drop(seq, 1))
    |> Enum.map(fn {el, prev} -> el - prev end)

    [sign | _] = diffs
    not Enum.any?(diffs, fn el -> is_bad?(el, sign) end)
  end

  defp is_safish?(seq) do
    is_safe?(seq) or Enum.any?(
      0..length(seq) - 1, 
      fn i -> (Enum.take(seq, i) ++ Enum.drop(seq, i + 1)) |> is_safe?() end
    )
  end

  defp is_bad?(diff, sign), do: diff * sign <= 0 or abs(diff) > 3

  defp parse_input(input_str) do
    input_str
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line) |> Enum.map(&String.to_integer/1) end)
  end
end
