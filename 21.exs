defmodule Aoc21 do
  def example() do
    """
    029A
    980A
    179A
    456A
    379A
    """
  end

  def part_one(input) do
    table = build_routes(2, {:num, &compare_moves/2}) |> IO.inspect()

    input 
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(
      fn code -> 
        {num_part, "A"} = Integer.parse(code)
        len = [?A | String.to_charlist(code)]
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(&(table[[?A, ?A | &1]] |> elem(1)))
        |> Enum.sum()
        len * num_part
      end
    )
    |> Enum.sum()
  end

  def part_two(input) do
    gold_num = make_golden(:num, 5)
    gold_dir = make_golden(:dir)

    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(
      fn code ->
        {num_part, "A"} = Integer.parse(code)

        len = code |> String.to_charlist() |> prepend()
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.flat_map(&(gold_num[&1]))
        |> iterate_codes(25, gold_dir)

        num_part * len
      end
    )
    |> Enum.sum()
  end

  defp prepend(code), do: [?A | code]

  defp iterate_codes(code, n, table) when is_list(code) do
    prepend(code)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.frequencies()
    |> iterate_freqs(n, table)
  end

  defp iterate_freqs(freqs, 0, _), do: freqs |> Enum.map(&elem(&1, 1)) |> Enum.sum()
  defp iterate_freqs(freqs, n, table) do
    freqs
    |> Enum.flat_map(
      fn {pair, n} ->
        prepend(table[pair])
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(&({&1, n}))
      end
    )
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {pair, ns} -> {pair, Enum.sum(ns)} end)
    |> iterate_freqs(n - 1, table)
  end

  defp make_golden(type, depth \\ 4) do
    tb = build_routes(depth, {type, nil})
    opts = if type == :num, do: numbers(), else: moves()
    product([opts, opts])
    |> Enum.map(
      fn pair ->
        path = ((1..depth |> Enum.map(fn _ -> ?A end)) ++ pair)
        |> make_path(tb, type)
        |> reduce_path_deep(depth)

        {pair, path}
      end
    )
    |> Enum.into(%{})
  end

  def make_path(state, table, type, acc \\ []) do
    case table[state] do
      {m, 1} -> Enum.reverse([m | acc])
      {m, _} -> make_path(update_state(state, m, type), table, type, [m | acc])
    end
  end

  def reduce_path(path, current \\ ?A, acc \\ [])
  def reduce_path([], _, acc), do: Enum.reverse(acc)
  def reduce_path([?A | rest], cur, acc), do: reduce_path(rest, cur, [cur | acc])
  def reduce_path([m | rest], cur, acc), do: reduce_path(rest, move_arr(cur, m), acc)

  def reduce_path_deep(path, 0), do: path
  def reduce_path_deep(path, n), do: reduce_path_deep(path, n - 1) |> reduce_path()

  def compare_moves({_m1, {_nm1, l1}}, {_m2, {_nm2, l2}}), do: l1 <= l2

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("21.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  def compute_path(table, code) when is_binary(code) do 
    compute_path(table, [?A | String.to_charlist(code)], 0)
  end
  def compute_path(_, [?A], acc), do: acc
  def compute_path(table, [a, b | rest], acc) do
    {_, len} = table[{?A, ?A, a, b}]
    compute_path(table, [b | rest], acc + len)
  end

  def build_routes(depth, {type, _} = opts) when is_integer(depth) do
    last = if type == :num, do: numbers(), else: moves()
    dirs = 1..depth |> Enum.map(fn _ -> moves() end)
    product(dirs ++ [last, last])
    |> Enum.map(&({&1, nil}))
    |> Enum.into(%{})
    |> fill_initial(last)
    |> build_routes(opts)
  end

  def build_routes(table, opts) do
    case Enum.reduce(table, {:not_found, table, opts}, &find_move/2) do
      {:ok, table, _} -> build_routes(table, opts)
      {:not_found, table, _} -> table
      err -> err
    end
  end

  defp update_table(table, new) do
    Enum.reduce(new, table, fn {s, m}, acc -> Map.put(acc, s, m) end)
  end

  defp fill_initial(table, opts) do
    as = table |> Enum.at(0) |> elem(0) |> Enum.drop(2) |> Enum.map(fn _ -> ?A end)
    update_table(table, opts |> Enum.map(fn x -> {as ++ [x, x], {?A, 1}} end))
  end

  defp find_move(state, acc)
  defp find_move(_, {:err, _, _} = acc), do: acc
  defp find_move({state, nil}, {_, table, {type, _cmp_moves} = opts} = acc) do
    case moves()
    |> Enum.map(fn m -> {m, table[update_state(state, m, type)]} end)
    |> Enum.reject(&is_nil(elem(&1, 1)))
    |> Enum.min(&compare_moves/2, fn -> nil end) do
      nil -> acc
      {m, {_, len}} -> {:ok, Map.put(table, state, {m, len + 1}), opts}
    end
  end
  defp find_move(_, acc), do: acc

  defp update_state(state, move, type, acc \\ [])
  defp update_state([p1, dst], move, type, acc) do
    p2 = case type do
      :num -> move_num(p1, move)
      :dir -> move_arr(p1, move)
    end
    if p2 == nil, do: nil, else: Enum.reverse([dst, p2 | acc])
  end
  defp update_state([p1 | rest], ?A, type, acc) do
    update_state(rest, p1, type, [p1 | acc])
  end
  defp update_state([p1 | rest], move, _, acc) do
    case move_arr(p1, move) do
      nil -> nil
      p2 -> Enum.reverse(acc) ++ [p2 | rest]
    end
  end

  defp move_num(?7, d), do: %{?> => ?8, ?v => ?4}[d]
  defp move_num(?8, d), do: %{?> => ?9, ?v => ?5, ?< => ?7}[d]
  defp move_num(?9, d), do: %{?< => ?8, ?v => ?6}[d]
  defp move_num(?4, d), do: %{?> => ?5, ?v => ?1, ?^ => ?7}[d]
  defp move_num(?5, d), do: %{?> => ?6, ?v => ?2, ?^ => ?8, ?< => ?4}[d]
  defp move_num(?6, d), do: %{?v => ?3, ?^ => ?9, ?< => ?5}[d]
  defp move_num(?1, d), do: %{?> => ?2, ?^ => ?4}[d]
  defp move_num(?2, d), do: %{?> => ?3, ?^ => ?5, ?< => ?1, ?v => ?0}[d]
  defp move_num(?3, d), do: %{?< => ?2, ?^ => ?6, ?v => ?A}[d]
  defp move_num(?0, d), do: %{?^ => ?2, ?> => ?A}[d]
  defp move_num(?A, d), do: %{?< => ?0, ?^ => ?3}[d]

  defp move_arr(?^, d), do: %{?> => ?A, ?v => ?v}[d]
  defp move_arr(?A, d), do: %{?< => ?^, ?v => ?>}[d]
  defp move_arr(?>, d), do: %{?^ => ?A, ?< => ?v}[d]
  defp move_arr(?v, d), do: %{?^ => ?^, ?> => ?>, ?< => ?<}[d]
  defp move_arr(?<, d), do: %{?> => ?v}[d]

  defp moves(), do: [?<, ?^, ?>, ?v, ?A]
  defp numbers(), do: Enum.concat(?0..?9, [?A])

  def product([list]), do: Enum.map(list, &([&1]))
  def product([list | rest]) do 
    Enum.flat_map(product(rest), fn t -> Enum.map(list, &([&1 | t])) end)
  end
end
