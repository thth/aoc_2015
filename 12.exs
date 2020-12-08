defmodule Twelve do
  def part_one(input) do
    Regex.scan(~r/(\d+|-\d+)/, input, capture: :all_but_first)
    |> Enum.map(fn [n] -> String.to_integer(n) end) 
    |> Enum.sum()
  end

  def part_two(input) do
    # splits json into individual characters but keeps [\-a-z0-9] grouped together
    splitter = ~r/(?<=[\-\w])(?=[^\-\w])|(?<=[^\-\w])(?=[\-\w])|(?<=[^\-\w])(?=[^\-\w])/
    Regex.split(splitter, input)
    |> Enum.map(fn chunk ->
      case Integer.parse(chunk) do
        {n, ""} -> n
        :error -> chunk
      end
    end)
    |> count()
  end

  defp count(list, counts \\ [])
  defp count(["}"], [{:obj, total}]), do: total
  defp count(["{"   | rest],                            counts), do: count(rest, [{:obj, 0} | counts])
  defp count(["["   | rest],                            counts), do: count(rest, [{:arr, 0} | counts])
  defp count(["]"   | rest], [{:arr, n}, {parent, m} | counts]), do: count(rest, [{parent, n + m} | counts])
  defp count(["}"   | rest], [{:red, _}              | counts]), do: count(rest, counts)
  defp count(["}"   | rest], [{:obj, n}, {parent, m} | counts]), do: count(rest, [{parent, n + m} | counts])
  defp count(["red" | rest], [{:obj, n}              | counts]), do: count(rest, [{:red, n} | counts])
  defp count([n     | rest], [{parent, acc}          | counts]) when is_integer(n),
    do: count(rest, [{parent, acc + n} | counts])
  defp count([_ | rest], counts), do: count(rest, counts)
end

input = File.read!("input/12.txt")

input
|> Twelve.part_one()
|> IO.inspect()

input
|> Twelve.part_two()
|> IO.inspect()
