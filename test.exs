defmodule Test do
    #a = 1..10
    #collection = Enum.chunk_every(a,3) #[[1,2,3],[4,5,6],[7,8,9],[10]]
    #function = &(&1+1)
    #mapFunc = fn x -> Enum.map(x, function) end
    #Enum.each(collection, &mapFunc.(&1))
    def split(collection, process_count) do
        tempList = Enum.to_list(collection) #converts collection to a list
        num = div(List.last(tempList), process_count) #num = the size of each of the sublists(assuming evenly divided)
        list = Enum.chunk_every(collection, num)
        list = List.replace_at(list, process_count-1, Enum.at(list, process_count-1)
        list = List.delete_at(List.replace_at(list, process_count-1, Enum.at(list, process_count-1) ++ Enum.at(list, process_count)), process_count)
        
        replacement = Enum.filter(Enum.at(list, process_count-1) , & !is_nil(&1))
        List.replace_at(list, process_count-1, replacement)

        Enum.split(collection, 3)
        #Enum.reject(Enum.at(list, process_count-1), &is_nil/1)
        #Enum.at(list, process_count-1)
    end
end

ExUnit.start()
defmodule MyTests do
  use ExUnit.Case
  import Test

  test "split" do
    collection = 1..10
    process_count = 3
    assert split(collection, process_count) == nil
  end
end