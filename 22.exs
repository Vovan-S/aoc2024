defmodule Aoc22 do
  def example(), do: [1, 10, 100, 2024]

  def part_one(initials, n) do
    initials
    |> Enum.map(&iterate(&1, n))
    |> Enum.sum()
  end

  def part_two(initials, n) do
    initials
    |> Enum.with_index()
    |> Enum.reduce(
      %{},
      fn {x, i}, seqs ->
        [x | Enum.scan(1..n, x, fn _, acc -> next(acc) end)]
        |> Enum.map(&rem(&1, 10))
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [a, b] -> {b, b - a} end)
        |> Enum.chunk_every(4, 1, :discard)
        |> Enum.reduce(
          seqs, 
          fn [_, _, _, {price, _}] = seq, acc ->
            prefix = Enum.map(seq, &elem(&1, 1))
            m = acc[prefix] || %{}
            Map.put(acc, prefix, Map.put_new(m, i, price))
          end
        )
      end
    )
    |> Enum.max_by(fn {_, m} -> m |> Enum.map(&elem(&1, 1)) |> Enum.sum() end)
    |> elem(1)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("22.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)

    case part do
      1 -> part_one(input, 2000)
      2 -> part_two(input, 2000)
    end
  end

  @mask Bitwise.bsl(1, 24) - 1
  defp mix_prune(secret, n), do: Bitwise.bxor(secret, n) |> Bitwise.band(@mask)

  def next(secret) do
    secret = mix_prune(secret, Bitwise.bsl(secret, 6))
    secret = mix_prune(secret, Bitwise.bsr(secret, 5))
    mix_prune(secret, Bitwise.bsl(secret, 11))
  end

  defp iterate(x, 0), do: x
  defp iterate(x, n), do: next(x) |> iterate(n - 1)
end
