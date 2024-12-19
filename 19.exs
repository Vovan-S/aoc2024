defmodule Aoc19 do 
  def example() do
    """
    r, wr, b, g, bwu, rb, gb, br

    brwrr
    bggr
    gbbr
    rrbgbr
    ubwu
    bwurrg
    brgr
    bbrgwb
    """
  end

  def part_one(input) do
    {towels, designs} = parse_input(input)
    towels = towels |> Enum.sort_by(&length/1, :desc)
    Enum.count(designs, &valid?(&1, towels))
  end

  def part_two(input) do
    {towels, designs} = parse_input(input)
    
    designs
    |> Enum.map(&n_options(&1, towels))
    |> Enum.sum()
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("19.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp valid?(design, opts)
  defp valid?(nil, _), do: false
  defp valid?([], _), do: true
  defp valid?(design, opts) do
    opts
    |> Enum.map(&remove_prefix(design, &1))
    |> Enum.any?(&valid?(&1, opts))
  end

  def n_options(design, initial, states \\ [{[], 1}])
  def n_options(_, _, []), do: 0
  def n_options([], _, states) do
    Enum.find(states, {nil, 0}, fn {ls, _} -> ls == [] end) |> elem(1)
  end
  def n_options([c | rest], initial, states) do
    states = states
    |> Enum.flat_map(&process_state(&1, initial, c))
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {ls, ns} -> {ls, Enum.sum(ns)} end)

    n_options(rest, initial, states)
  end

  defp process_state(state, initial, c)
  defp process_state({[], n}, initial, c) do 
    Enum.flat_map(initial, fn opt -> process_state({opt, n}, initial, c) end)
  end
  defp process_state({[c1 | _], _}, _, c) when c1 != c, do: []
  defp process_state({[_ | rest], n}, _, _), do: [{rest, n}]

  defp remove_prefix(list, prefix)
  defp remove_prefix(list, []), do: list
  defp remove_prefix([], _), do: nil
  defp remove_prefix([c1 | _], [c2 | _]) when c1 != c2, do: nil
  defp remove_prefix([_ | rest1], [_ | rest2]), do: remove_prefix(rest1, rest2)

  defp parse_input(input) do
    [towels, designs] = input |> String.trim() |> String.split("\n\n")
    towels = towels |> String.split(", ") |> Enum.map(&String.to_charlist/1)
    designs = designs |> String.split("\n") |> Enum.map(&String.to_charlist/1)
    {towels, designs}
  end
end
