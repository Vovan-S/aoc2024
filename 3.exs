defmodule Aoc3 do
  def example() do
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
  end

  def example2() do
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
  end

  def part_one(input) do
    input
    |> find_mul()
    |> Enum.map(fn [_, a, b] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> find_all_instructions()
    |> Enum.reduce({true, 0}, &process_token/2)
    |> elem(1)
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("3.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp process_token(token, acc)
  defp process_token(["don't()"], {_, sum}), do: {false, sum}
  defp process_token(["do()"], {_, sum}), do: {true, sum}
  defp process_token([_, _, _], {false, _} = acc), do: acc
  defp process_token([_, a, b], {true, sum}) do
    {true, sum + String.to_integer(a) * String.to_integer(b)}
  end

  defp find_mul(input) do
    ~r/mul\((\d{1,3}),(\d{1,3})\)/
    |> Regex.scan(input)
  end

  defp find_all_instructions(input) do
    ~r/mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)/
    |> Regex.scan(input)
  end
end
