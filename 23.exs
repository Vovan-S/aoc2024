defmodule Aoc23 do
  def example() do
    """
    kh-tc
    qp-kh
    de-cg
    ka-co
    yn-aq
    qp-ub
    cg-tb
    vc-aq
    tb-ka
    wh-tc
    yn-cg
    kh-ub
    ta-co
    de-co
    tc-td
    tb-wq
    wh-td
    ta-ka
    td-qp
    aq-cg
    wq-ub
    ub-vc
    de-ta
    wq-aq
    wq-vc
    wh-yn
    ka-de
    kh-ta
    co-tc
    wh-qp
    tb-vc
    td-yn
    """
  end

  def part_one(input) do
    ns = parse_input(input) |> get_neighborhoods()

    ns
    |> Enum.flat_map(&get_connected_3(&1, ns))
    |> MapSet.new()
    |> Enum.count(fn l -> Enum.any?(l, &String.starts_with?(&1, "t")) end)
  end

  def part_two(input) do
    ns = parse_input(input) |> get_neighborhoods()

    ns
    |> Enum.flat_map(&get_connected_3(&1, ns))
    |> MapSet.new()
    |> find_largest(ns)
    |> Enum.at(0)
    |> Enum.join(",")
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("23.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp get_neighborhoods(edges) do
    Enum.reduce(
      edges, 
      %{},
      fn [a, b], acc ->
        n_a = (acc[a] || MapSet.new()) |> MapSet.put(b)
        n_b = (acc[b] || MapSet.new()) |> MapSet.put(a)
        acc |> Map.put(a, n_a) |> Map.put(b, n_b)
      end
    )
  end

  defp get_connected_3({a, n}, ns) do
    Aoc21.product([n, n])
    |> Enum.filter(fn [b, c] -> b != c and Enum.member?(ns[c], b) end)
    |> Enum.map(fn [b, c] -> [a, b, c] |> Enum.sort() end)
  end

  defp find_largest(comps, ns) do
    case comps |> Enum.flat_map(&enlarge_component(&1, ns)) do
      [] -> comps
      new_comps -> find_largest(MapSet.new(new_comps), ns)
    end
  end

  defp enlarge_component([a | rest], ns) do
    ns[a]
    |> Enum.reject(&Enum.member?(rest, &1))
    |> Enum.filter(fn b -> Enum.all?(rest, &Enum.member?(ns[b], &1)) end)
    |> Enum.map(fn b -> [b, a | rest] |> Enum.sort() end)
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "-"))
  end
end
