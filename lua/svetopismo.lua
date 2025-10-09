local url = "https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/lua/sp.lua"

local handle = io.popen("curl -s -L " .. url)
if not handle then
    print("Није могуће покренути curl.")
    return
end

local kod = handle:read("*a")
handle:close()

if not kod or kod == "" then
    print("Провјерите интернет конекцију.")
    return
end

local fn, err = load(kod)
if not fn then
    print("Грешка при учитавању скрипте: " .. tostring(err))
    return
end

fn()
