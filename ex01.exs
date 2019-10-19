#####################################################################
#
# Read the notes in the tests, then implement the code in the module
# at the end of the file.
#
#####################################################################

# In this exercise you'll implement a simple process that acts as a
# counter. Each time you send it `{:next, from}`, it will send to
# `from` the tuple `{:next_is, value}`, and that value will increase
# by one on each call. Your code will allow you to set the initial
# value returned.


ExUnit.start()

defmodule Test do
  use ExUnit.Case

  # STEP 1:
  #
  # This test assumes you have a function `Ex01.counter` that
  # can be spawned and which handles the `{:next, from}` message.
  # Your job is to implement the body of `counter` in the definition
  # of the Ex01 module tht follows these tests.
  #
  # Implement just the `counter` function, then run the tests using
  #
  #      $ elixir ex01.exs
  #
  # 5 points


  test "basic message interface" do
    count = spawn Ex01, :counter, []
    send count, { :next, self() }
    assert_receive({ :next_is, value }, 10)
    assert value == 0

    send count, { :next, self() }
    assert_receive({ :next_is, value }, 10)
    assert value == 1
  end

  # STEP 2:
  #
  # Now write code in the `Ex01.new_counter` and
  # `Ex01.next_value` that wrap the counter function, giving it
  # a higher level API. The test below shows how this API will be used.
  #
  # To test your functions, you need to delete the following line


  # then rerun `elixir ex01.exs`
  #
  # 5 points

  test "higher level API interface" do
    count = Ex01.new_counter(5)
    assert  Ex01.next_value(count) == 5
    assert  Ex01.next_value(count) == 6
  end

end


########################################
#                                      #
# This is the code you'll be changing  #
#                                      #
########################################

defmodule Ex01 do

  def counter(value \\ 0) do
    receive do
      {:next,from} ->
        send from, {:next_is,value}
        counter(value + 1)
    end
    
  end

  def new_counter(initial_value \\ 0) do
    spawn fn -> counter(initial_value) 
    end
  end

  def next_value(counter_pid) do
    send counter_pid, {:next,self()}
    receive do
      {next_is,value} -> value
    end
  end
end
