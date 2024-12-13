defmodule Aoc13 do
  def example() do
    """
    Button A: X+94, Y+34
    Button B: X+22, Y+67
    Prize: X=8400, Y=5400

    Button A: X+26, Y+66
    Button B: X+67, Y+21
    Prize: X=12748, Y=12176

    Button A: X+17, Y+86
    Button B: X+84, Y+37
    Prize: X=7870, Y=6450

    Button A: X+69, Y+23
    Button B: X+27, Y+71
    Prize: X=18641, Y=10279
    """
  end

  def part_one(input) do
    input
    |> parse_input()
    |> Enum.map(&solve_linear/1)
    |> Enum.filter(fn {s, a, b} -> s == :ok and valid?(a) and valid?(b) end)
    |> Enum.map(fn {_, a, b} -> a * 3 + b end)
    |> Enum.sum()
  end

  def part_two(input) do
    dx = 10000000000000

    input
    |> parse_input()
    |> Enum.map(fn {col_a, col_b, {x, y}} -> {col_a, col_b, {x + dx, y + dx}} end)
    |> Enum.map(&solve_linear/1)
    |> Enum.filter(fn {s, a, b} -> s == :ok and valid2?(a) and valid2?(b) end)
    |> Enum.map(fn {_, a, b} -> a * 3 + b end)
    |> Enum.sum()
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("13.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(&parse_problem/1)
  end

  defp solve_linear({{0, 0}, {0, 0}, {0, 0}}), do: {:any, nil, nil}
  defp solve_linear({{0, 0}, {0, 0}, {_, _}}), do: {:never, nil, nil}
  defp solve_linear({col_a, col_b, col_r}) do
    case det({col_a, col_b}) do
      0 -> multiple_solutions({col_a, col_b, col_r})
      d -> {:ok, det({col_r, col_b}) / d, det({col_a, col_r}) / d}
    end
  end

  defp multiple_solutions({{xa, ya}, {xb, yb}, {xr, yr}}) do
    cond do
      xa != 0 and xa * yr != ya * xr -> {:never, nil, nil}
      xa != 0 -> {:many, {xr / xa, -xb / xa}, {0, 1}}
      xb != 0 and xb * yr != yb * xr -> {:never, nil, nil}
      xb != 0 -> {:many, {0, 1}, {xr / xb, -xa / xb}}
      true -> multiple_solutions({{ya, xa}, {yb, xb}, {yr, xr}})
    end
  end

  defp det({{x1, y1}, {x2, y2}}), do: x1 * y2 - y1 * x2

  defp parse_problem(input) do
    [xa, ya, xb, yb, xr, yr] = 
      Regex.scan(~r/\d+/, input) 
      |> Enum.map(fn [x] -> String.to_integer(x) end)
    {{xa, ya}, {xb, yb}, {xr, yr}}
  end

  defp valid?(a), do: trunc(a) == a and 0 <= a and a <= 100
  defp valid2?(a), do: trunc(a) == a and 0 <= a
end
