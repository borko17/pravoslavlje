-- run.lua
-- Preuzima i pokreće start.lua iz GitHub repozitorijuma

local url = "https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/lua/sp.lua"

print("Преузимам скрипту...")

local handle = io.popen("curl -s -L " .. url)
if not handle then
  print("Није могуће покренути curl.")
  return
end

local kod = handle:read("*a")
handle:close()

if not kod or kod == "" then
  print("Скрипта није преузета.")
  return
end

local fn, err = load(kod)
if not fn then
  print("Грешка при учитавању скрипте: " .. tostring(err))
  return
end

print("Покретање скрипте...")
fn()