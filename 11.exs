defmodule Aoc11 do
  def example(), do: "125 17"

  def part_one(input) do
    input
    |> parse_input()
    |> blink(25)
    |> Enum.count()
  end

  def part_two(input) do
    input
    |> parse_input()
    |> Enum.map_reduce(%{}, fn el, c -> blink_cached(el, 75, c) end)
    |> elem(0)
    |> Enum.sum()
  end

  defp blink(stones, 0), do: stones
  defp blink(stones, n_times), do: blink(transform_stones(stones), n_times - 1)

  defp blink_cached(n, n_times, cache)
  defp blink_cached(n, 0, cache), do: {1, cache}
  defp blink_cached(n, n_times, cache) do
    cache = Map.put_new_lazy(cache, n, &default_cache/0)
    cached = cache |> Map.get(n)
    case cached |> elem(n_times - 1) do
      nil -> 
        {sums, cache} = stone_rule(n)
        |> Enum.map_reduce(cache, fn el, c -> blink_cached(el, n_times - 1, c) end)

        result = Enum.sum(sums)
        {result, cache |> Map.put(n, put_elem(cached, n_times - 1, result))}

      result ->
        {result, cache}
    end
  end

  defp default_cache(), do: Tuple.duplicate(nil, 75)

  defp parse_input(input) do
    input 
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("11.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp transform_stones(stones), do: Enum.flat_map(stones, &stone_rule/1)

  def digits(n) when n < 10, do: 1
  def digits(n), do: digits(div(n, 10)) + 1

  defp stone_rule(0), do: [1]
  defp stone_rule(n) do
    case digits(n) do
      d when rem(d, 2) == 0 -> split_number(n, d)
      _ -> [n * 2024]
    end
  end

  defp split_number(n, n_digits) do
    m = pow(10, div(n_digits, 2))
    [div(n, m), rem(n, m)]
  end

  defp pow(_, 0), do: 1
  defp pow(x, n) when n > 0, do: x * pow(x, n - 1)
end
