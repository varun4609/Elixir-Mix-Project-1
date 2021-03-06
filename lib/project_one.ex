defmodule ProjectOne do
  def spawn_link(xlimits) do
    spawn_link(__MODULE__, :init, [xlimits])
  end

  def init(xlimits, size) do
    #prev_real = System.monotonic_time(:millisecond)
    num_proc = 1000000
    threshold = min(xlimits, num_proc)

    limits = Enum.to_list(1..threshold)
    Process.flag :trap_exit, true

    children_pids = Enum.map(limits, fn(limit_num) ->
      pid = run_child(limit_num, size)
      {pid, limit_num}
    end) |> Enum.into(%{})

    arg = Enum.to_list(threshold + 1..xlimits)
    if xlimits > num_proc do
      loop(children_pids, arg, size)
    end
    #current_real = System.monotonic_time(:millisecond)
    #diff_real = current_real - prev_real
    #IO.puts diff_real
  end

  def loop(_, list, _) when list == [] do
    :parentExit
  end
  def loop(children_pids, [head | tail], size) do
    receive do
      {:EXIT, pid, _} = _->
        #IO.puts "Parent got message: #{inspect msg}"

        {_, children_pids} = pop_in children_pids[pid] #_ = limit
        new_pid = run_child(head, size)

        children_pids = put_in children_pids[new_pid], head

        #IO.puts "Restart children #{inspect pid}(limit #{limit}) with new pid #{inspect new_pid}"

        loop(children_pids, tail, size)
    end
  end

  def run_child(limit, size) do
    spawn_link(Child, :init, [limit, size])
  end
end

defmodule Child do
  def init(limit, size) do
    #IO.puts "Start child with limit #{limit} pid #{inspect self()}"
    loop(limit, size)
  end

  def loop(0, _), do: :ok
  def loop(n, size) when n > 0 do
    #IO.puts "Process #{inspect self()} list #{n} to #{n + 25}"
    MathWork.parent(n, size)
    #loop(n-1)
  end
end

defmodule MathWork do
  def main do
    IO.puts("Welcome :)")
  end

  #def parent(start_num, end_num, _) when end_num > start_num do
  #  :parentExit
  #end

  def parent(start_num, recur_level) do
    ans = loop(start_num, recur_level)
    #IO.puts("The answer is :#{ans}")
    #if ans is perfect square, exit. else continue
    temp = is_sqrt_natural?(ans)
    if (temp == true) do
      IO.puts("#{start_num}")
    end
  end

  def is_sqrt_natural?(n) when is_integer(n) do
    :math.sqrt(n) |> :erlang.trunc |> :math.pow(2) == n
  end

  def loop(num, recur_level) when recur_level == 1 do
    #IO.puts "The number is :#{num} end"
    num*num
  end

  #not really required
  #def loop(num, _) when num <= 1 do
    #IO.puts "The number is :#{num} end"
  #  num
  #end

  def loop(num, recur_level) do
    #IO.puts "The number is :#{num}"
    num*num + loop(num + 1, recur_level - 1)
  end
end

#ProjectOne.init(40, 24)

#Process.sleep 10_00
