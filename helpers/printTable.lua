function tprint(tbl)
    for key, value in pairs(yourTable) do
       --[[  if type(value) == "table" then 
            tprint(value) 
        end ]]
        print(key, value)
    end
end
