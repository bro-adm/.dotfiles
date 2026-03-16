local function greet(name)
  return print(("Hello from Fennel, " .. name .. "!"))
end
return {greet = greet}
