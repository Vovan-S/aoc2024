defmodule Aoc5 do
  def example() do
    """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """
  end

  def part_one(input) do
    {rules, updates} = parse_input(input)

    updates
    |> Enum.filter(&is_ordered?(&1, rules))
    |> collect()
  end

  def part_two(input) do
    {rules, updates} = parse_input(input)

    updates
    |> Enum.reject(&is_ordered?(&1, rules))
    |> Enum.map(fn list -> Enum.sort(list, &is_less?(&1, &2, rules)) end)
    |> collect()
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("5.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp parse_input(input) do
    [ordering, updates] = input |> String.trim() |> String.split("\n\n")

    ordering = ordering 
    |> String.split("\n")
    |> Enum.map(
      fn line -> 
        line 
        |> String.split("|") 
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
    |> Enum.into(MapSet.new())

    updates = updates
    |> String.split("\n")
    |> Enum.map(
      fn line -> 
        line 
        |> String.split(",") 
        |> Enum.map(&String.to_integer/1) 
      end)

    {ordering, updates}
  end

  defp collect(updates) do
    updates
    |> Enum.map(fn list -> Enum.at(list, div(length(list), 2)) end)
    |> Enum.sum()
  end

  defp is_ordered?(line, rules) do
    line
    |> Enum.chunk_every(length(line), 1)
    |> Enum.all?(
      fn [el | rest] -> 
      Enum.all?(rest, fn el2 -> MapSet.member?(rules, {el, el2}) end) 
    end)
  end

  defp is_less?(a, b, rules) do
    cond do
      MapSet.member?(rules, {a, b}) -> true
      true -> false
    end
  end
end
