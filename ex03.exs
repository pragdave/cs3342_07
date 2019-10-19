defmodule Ex03 do

  @moduledoc """

  `Enum.map` takes a collection, applies a function to each element in
  turn, and returns a list containing the result. It is an O(n)
  operation.

  Because there is no interaction between each calculation, we could
  process all elements of the original collection in parallel. If we
  had one processor for each element in the original collection, that
  would turn it into an O(1) operation in terms of elapsed time.

  However, we don't have that many processors on our machines, so we
  have to compromise. If we have two processors, we could divide the
  map into two chunks, process each independently on its own
  processor, then combine the results.

  You might think this would halve the elapsed time, but the reality
  is that the initial chunking of the collection and the eventual
  combining of the results both take time. As a result, the speed up
  will be less that a factor of two. If the work done in the mapping
  function is time consuming, then the speedup factor will be greater,
  as the overhead of chunking and combining will be relatively less.
  If the mapping function is trivial, then parallelizing the code will
  actually slow it down.

  Your mission is to implement a function

      pmap(collection, process_count, func)

  This will take the collection, split it into n chunks, where n is
  the process count, and then run each chunk through a regular map
  function, but with each map running in a separate process. It then
  combines the results (in the correct order). It should use
  spawn and message passing (and not agents, tasks, or genservers).
  It should not use any conditional logic (if/cond/case).

  Useful functions include `Enum.map/3`, `Enum.chunk_every/4`, and
  `Enum.flat_map/1`.

  Feel free to use one or more helper functions... (there may be some
  extra credit for code that is well factored and that looks good).
  My solution is about 40 lines (including some blank ones) and
  six helper functions.

  35 points:
     it works and passes all tests:    25
     it contains no conditional logic:  3
     it is nicely structured            7
  """
  #pmap(1..10, 1, &(&1+1)

  def pmap(collection, process_count, function) do
      #divideCollection will divide collection into process_count chunks
      #main_function will spawn threads with the dividedCollection chunks in each thread
      #thread_flattener will take the dividedCollection and flatten it to a single collection
      divideCollection(collection,process_count) |> main_function(function) |> thread_flattener()
  end

  # and here...
  def divideCollection(collection, process_count) do
  #divides collection into chunks based on process_count
  collection =  Enum.chunk_every(collection, div(Enum.count(collection), process_count),div(Enum.count(collection), process_count),[])
  end

  def main_function(collection_chunks, function) do
      #for each new chunk, a thread is spawned
      #then the thread functions will return the updated chunks
       Enum.map(collection_chunks, fn current_collection_chunk -> spawn(Ex03, :thread_function, [current_collection_chunk, function, self()]) end)
        |> Enum.map(fn thread_process ->
        ( receive do
          {^thread_process, final_collection} ->
            final_collection
        end)
        end)
  end

  def thread_function(current_collection_chunk, function, from) do
    #Each element inside of the chunk will be put through the function
    #The updated collection will be sent back to main_function
    updated_collection_chunk = Enum.map(current_collection_chunk, fn current_collection_chunk_element -> function.(current_collection_chunk_element) end)
    send from, {self(), updated_collection_chunk}
  end

  def thread_flattener(final_collection) do
    #The divided collection is flatten into a single collection
    Enum.flat_map(final_collection, fn x -> x end)
  end
end

#^pid
#send to threads
#in same method, recieve results in a single map
#in the end, use flatten so its a single
######### no changes below here #############

ExUnit.start
defmodule TestEx03 do
  use ExUnit.Case
  import Ex03

  @expected 2..11 |> Enum.into([])

  test "pmap with 1 process" do
    assert pmap(1..10, 1, &(&1+1)) == @expected
  end

  test "pmap with 2 processes" do
    assert pmap(1..10, 2, &(&1+1)) == @expected
  end

  test "pmap with 3 processes (doesn't evenly divide data)" do
    assert pmap(1..10, 3, &(&1+1)) == @expected
  end

  test "actually reduces time" do
    range = 1..6

    # random calculation to burn some time.
    # Note that the sleep value reduces
    # with successive values, so the
    # later values will complete firest. Does
    # your code correctl;y gather the results in the
    # right order?

    calc  = fn n -> :timer.sleep(10-n); n*3 end

    { time1, result1 } = :timer.tc(fn -> pmap(range, 1, calc) end)
    { time2, result2 } = :timer.tc(fn -> pmap(range, 2, calc) end)
    { time3, result3 } = :timer.tc(fn -> pmap(range, 3, calc) end)

    expected = 1..6 |> Enum.map(&(&1*3))
    assert result1 == expected
    assert result2 == expected
    assert result3 == expected

    assert time2 < time1 * 0.75   # in theory should be 0.5
    assert time3 < time1 * 0.45   # and 0.33
  end

end
