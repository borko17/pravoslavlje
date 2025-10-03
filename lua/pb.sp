-- start.lua (čist, bez ikonica)

print("=== Православна библиотека ===")
print("1. Свето Писмо")
print("2. Житије светих")
print("3. Молитвеник")

io.write("\nИзаберите број: ")
local izbor = input()

local linkovi = {
  ["1"] = "https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/lua/sp.lua",
  ["2"] = "https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/lua/zitije.lua",
  ["3"] = "https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/lua/molitvenik.lua"
}

if izbor == "" then
  print("С Богом!")
  return
end

local url = linkovi[izbor]
if not url then
  print("Погрешан избор.")
  return
end

print("Преузимање скрипте са GitHub-а...")

local handle = io.popen("curl -s -L " .. url)
if not handle then
  print("Није могуће покренути curl.")
  return
end

local kod = handle:read("*a")
handle:close()

if not kod or kod == "" then
  print("Грешка: скрипта није преузета.")
  return
end

local fn, err = load(kod)
if not fn then
  print("Грешка при учитавању: " .. tostring(err))
  return
end

print("Покретање скрипте...\n")
fn()
