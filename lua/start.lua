-- start.lua
print("=== Православна библиотека ===")
print("1. Свето Писмо")
print("2. Житије Светих")
print("3. Молитвеник")
print("0. Излаз")

io.write("\nИзабери број: ")
local izbor = input("*l")

-- Mapa: broj -> GitHub link do skripte
local linkovi = {
  ["1"] = "https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/lua/sp.lua",
  ["2"] = "https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/lua/zitije.lua",
  ["3"] = "https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/lua/molitvenik.lua"
}

if izbor == "0" or izbor == "" then
  print("С Богом!")
  os.exit()
end

local url = linkovi[izbor]

if not url then
  print("Погрешан избор.")
  os.exit(1)
end

print("Преузимање изабране скрипте са GitHub-а...")

-- Преузимање кода преко curl
local temp_file = "temp.lua"
os.execute("curl -s -L --compressed " .. url .. " -o " .. temp_file)

local fn, err = loadfile(temp_file)
if not fn then
  print("Грешка при учитавању: " .. err)
  os.exit(1)
end
fn()


if not handle then
  print("Није могуће покренути 'curl'.")
  os.exit(1)
end

local kod = handle:read("*a")
handle:close()

if not kod or kod == "" then
  print("Грешка: скрипта није преузета.")
  os.exit(1)
end

-- Учитавање и покретање скрипте у глобалном опсегу
local fn, err = load(kod)
if not fn then
  print("Грешка при учитавању: " .. err)
  os.exit(1)
end

print("Покретање скрипте...\n")
fn()
