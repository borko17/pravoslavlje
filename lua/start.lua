-- start.lua (LOAD varijanta)
print("=== Православна библиотека ===")
print("1. Свето Писмо")
print("2. Житије Светих")
print("3. Молитвеник")
print("0. Излаз")

io.write("\nИзабери број: ")
local izbor = input()  -- u luaj-jse koristiš input()

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
  print("⚠️ Погрешан избор.")
  os.exit(1)
end

print("📥 Преузимање изабране скрипте...")

local handle = io.popen("curl -s -L --compressed " .. url)
if not handle then
  print("🚫 Није могуће покренути 'curl'.")
  os.exit(1)
end

local kod = handle:read("*a")
handle:close()

if not kod or kod == "" then
  print("🚫 Грешка: скрипта није преузета.")
  os.exit(1)
end

local fn, err = load(kod)
if not fn then
  print("⚠️ Грешка при учитавању: " .. err)
  os.exit(1)
end

print("▶️ Покретање...\n")
fn()