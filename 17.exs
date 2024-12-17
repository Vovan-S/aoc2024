defmodule Aoc17 do
  defmodule VM do
    defstruct a: 0, b: 0, c: 0, prog: []
  end

  def example() do
    """
    Register A: 729
    Register B: 0
    Register C: 0

    Program: 0,1,5,4,3,0
    """
  end

  def example2() do
    """
    Register A: 2024
    Register B: 0
    Register C: 0

    Program: 0,3,5,4,3,0
    """
  end

  def part_one(input) do
    tb = {:adv, :bxl, :bst, :jnz, :bxc, :out, :bdv, :cdv}
    {:ok, _, out} = input
    |> parse_input()
    |> decode_ops(tb)
    |> run()

    out |> Enum.reverse() |> Enum.join(",") |> IO.puts()
  end

  @doc """
  After analysis of given program (which has been done by hand) I found out,
  that 3 least significant bits of A will depend only on first output token and
  10 bits of A. The same rule applies to the next 3 bits and bits 4-14
  (assuming that the first 3 bits are already evaluated). The catch is that
  first 3 bits are not evaluated yet - there are many options of 10 bits
  numbers, that can be used, but their amount is significantly less, then 2^10.
  Using this cut of number of options, I simply brute force all the digits :)
  """
  def part_two(input) do
    tb = {:adv, :bxl, :bst, :jnz, :bxc, :out, :bdv, :cdv}
    %{prog: output} = vm = parse_input(input)
    vm = decode_ops(vm, tb)

    range = 1..10000

    1..length(output)
    |> Enum.map(&Enum.take(output, &1))
    |> Enum.reduce(
      {[0], 1},
      fn outs, {opts, m} ->
        opts = opts
        |> Enum.map(&rem(&1, m))
        |> MapSet.new()
        |> Enum.flat_map(fn o -> Enum.map(range, &(&1 * m + o)) end)
        |> Enum.filter(&matches?(vm, &1, outs))

        {opts, m * 8}
      end
    )
    |> elem(0)
    |> Enum.min()
  end

  defp matches?(vm, a, outs) do
    {:ok, _, res} = run(%{vm | a: a})
    res |> Enum.reverse() |> Enum.take(length(outs)) == outs
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("17.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  def run(vm), do: run(vm, vm.prog, [])

  defp run(vm, [], out), do: {:ok, vm, out}
  defp run(vm, [:adv, arg | rest], out), do: run(div_op(vm, :a, arg), rest, out)
  defp run(vm, [:bdv, arg | rest], out), do: run(div_op(vm, :b, arg), rest, out)
  defp run(vm, [:cdv, arg | rest], out), do: run(div_op(vm, :c, arg), rest, out)
  defp run(vm, [:bxl, arg | rest], out) do
    run(%{vm | b: Bitwise.bxor(vm.b, arg)}, rest, out)
  end
  defp run(vm, [:bxc, _ | rest], out) do
    run(%{vm | b: Bitwise.bxor(vm.b, vm.c)}, rest, out)
  end
  defp run(vm, [:bst, arg | rest], out) do 
    run(%{vm | b: rem(comb(vm, arg), 8)}, rest, out)
  end
  defp run(vm, [:jnz, _ | rest], out) when vm.a == 0, do: run(vm, rest, out)
  defp run(vm, [:jnz, arg | _], out), do: run(vm, Enum.drop(vm.prog, arg), out)
  defp run(vm, [:out, arg | rest], out) do 
    run(vm, rest, [comb(vm, arg) |> rem(8) | out])
  end

  defp comb(_, arg) when arg < 4, do: arg
  defp comb(vm, 4), do: vm.a
  defp comb(vm, 5), do: vm.b
  defp comb(vm, 6), do: vm.c

  defp div_op(vm, reg, arg) do
    Map.put(vm, reg, vm.a |> div(Integer.pow(2, comb(vm, arg))))
  end

  defp decode_ops(%VM{prog: prog} = vm, tb) do
    prog = prog
    |> Enum.chunk_every(2, 2)
    |> Enum.flat_map(fn [op, arg] -> [elem(tb, op), arg] end)

    %{vm | prog: prog}
  end

  defp parse_input(input) do
    [a, b, c | prog] = Regex.scan(~r/-?\d+/, input)
    |> Enum.map(fn [x] -> String.to_integer(x) end)

    %VM{a: a, b: b, c: c, prog: prog}
  end
end
