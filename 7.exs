defmodule Aoc7 do
  def example() do
    """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """
  end

  def part_one(input) do
    input
    |> parse_input()
    |> Enum.filter(fn {res, ops} -> solvable?(res, Enum.reverse(ops)) end)
    |> Enum.map(fn {res, _} -> res end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse_input()
    |> Enum.filter(fn {res, ops} -> solvable2?(res, Enum.reverse(ops)) end)
    |> Enum.map(fn {res, _} -> res end)
    |> Enum.sum()
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("7.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp magnitude(n), do: magnitude(n, 1)
  defp magnitude(0, m), do: m
  defp magnitude(n, m), do: magnitude(div(n, 10), m * 10)

  defp solvable?(result, rev_operands)
  defp solvable?(result, [last]), do: result == last
  defp solvable?(result, [op | rest]) do
    if rem(result, op) == 0 do
      solvable?(div(result, op), rest) or solvable?(result - op, rest)
    else
      solvable?(result - op, rest)
    end
  end

  defp solvable2?(result, rev_operands)
  defp solvable2?(result, [last]), do: result == last
  defp solvable2?(result, [op | rest]) do
    m = magnitude(op)
    cond do
      rem(result, op) == 0 and solvable2?(div(result, op), rest) -> true
      rem(result, m) == op and solvable2?(div(result, m), rest) -> true
      true -> solvable2?(result - op, rest)
    end
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [result, operands] = String.split(line, ": ")
    result = String.to_integer(result)
    operands = operands |> String.split(" ") |> Enum.map(&String.to_integer/1)
    {result, operands}
  end
end
