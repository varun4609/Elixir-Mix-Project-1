[n,k] = System.argv
fn -> ProjectOne.init(String.to_integer(n), String.to_integer(k)) end
|> :timer.tc
|> elem(0)
|> Kernel./(1_000_000)
|> IO.puts
