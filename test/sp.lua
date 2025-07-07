--[[
  Скрипта учитава Свето Писмо у JSON формату са интернета,
  затим корисник уноси скраћенице одломака (нпр. "1moj1-5", "ps4-7"),
  скрипта проширује те одломке, претвара латиницу у ћирилицу,
  и приказује тражени текст или стихове.
]]

print("📥 Преузимање Светог Писма.. 7,7MB")
local handle = io.popen('curl -s https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/sveto_pismo.json')
local body = handle:read("*a")
handle:close()

if not body or body == "" then
  print("❌ Грешка: Није могуће преузети Свето Писмо. Проверите интернет конекцију.")
  while true do end
end

print("\n=== Свето писмо ===")
print("Доступне опције:")
print("- Унеси скраћеницу из Светог Писма\n- унеси 'с' за садржај или 'п' за помоћ\n- притисни Enter за излаз")
print("(скрипта подржава и уносе у латиници)\n")

local function prosiri_odlomke(odlomak)
  local naziv, brojevi = odlomak:match("^(.-)(%d[%d%-]*)$")
  if not naziv or not brojevi then return {odlomak} end
  local od, do_ = brojevi:match("^(%d+)%-(%d+)$")
  if od and do_ then
    od, do_ = tonumber(od), tonumber(do_)
    local lista = {}
    for i = od, do_ do table.insert(lista, naziv .. i) end
    return lista
  else
    return {odlomak}
  end
end

local lat2cir_map = {
  ["a"]="а", ["b"]="б", ["v"]="в", ["g"]="г", ["d"]="д", ["đ"]="ђ", ["e"]="е", ["ž"]="ж", ["z"]="з",
  ["i"]="и", ["j"]="ј", ["k"]="к", ["l"]="л", ["m"]="м", ["n"]="н", ["o"]="о", ["p"]="п", ["r"]="р",
  ["s"]="с", ["t"]="т", ["ć"]="ћ", ["u"]="у", ["f"]="ф", ["h"]="х", ["c"]="ц", ["č"]="ч", ["š"]="ш"
}

local function latinica_u_cirilicu_ime(s)
  return s:lower():gsub("[%z\1-\127\194-\244][\128-\191]*", function(c)
    return lat2cir_map[c] or c
  end)
end

local function uredi_tekst_u_zagradama(sadrzaj)
  sadrzaj = sadrzaj:gsub("%s*;%s*", "; "):gsub("[^;]%s+", function(r)
    if r:sub(1,1) ~= ";" then return r:sub(1,1) end end):gsub("; %s+", "; "):lower()
  if sadrzaj:match("^%d%d?$") then return "[" .. sadrzaj .. "]" else return "\n[" .. sadrzaj .. "]\n" end
end

local alias_map = {
  ["пс"]="пс1-151", 
  ["зач1"] = "мт1,1-3; мт2,1,2",
}

local prvi_put = true
while true do
  if not prvi_put then io.write("> ") end
  local unos = input()
  if not unos or unos == "" then break end

  -- Претвори у ћирилицу и раздвој вишеструке уносе
  unos = latinica_u_cirilicu_ime(unos)
  for deo in unos:gmatch("[^;%s]+") do
    -- Уклони † * § . , са почетка и краја
    deo = deo:gsub("^[†*§%.,!\"'%-]+", ""):gsub("[†*§%.,!\"'%-]+$", "")
    local naziv, stihovi = deo:match("^([^,]+),?(.*)$")

    if alias_map[naziv] then
  local alias_unos = alias_map[naziv]
  print("📖 Проширени унос: " .. alias_unos)
  deo = alias_unos  -- преусмери цео унос у променљиву `deo`
  naziv, stihovi = deo:match("^([^,]+),?(.*)$")
end

    local odlomci = prosiri_odlomke(naziv)
    for _, od in ipairs(odlomci) do
      local pattern = '"' .. od .. '"%s*:%s*"([^"]-)"%s*[,\n}]'
      local tekst = body:match(pattern)

      if not tekst then
        print("🚧 Нема одломка са именом '" .. od .. "'.")
      else
        local linije = {}
        for lin in tekst:gmatch("[^\r\n]+") do table.insert(linije, lin) end

        if stihovi ~= "" then
          local ciljani = {}
          for deo in stihovi:gmatch("[^,]+") do
            local p1, p2 = deo:match("^(%d+)%-(%d+)$")
            if p1 and p2 then for i = tonumber(p1), tonumber(p2) do ciljani[i] = true end
            else local b = tonumber(deo); if b then ciljani[b] = true end end
          end

          if next(ciljani) then
            local izabrano = {}
            for _, lin in ipairs(linije) do
              local broj = tonumber(lin:match("^(%d+)%."))  
              if broj and ciljani[broj] then table.insert(izabrano, lin) end
            end

            if #izabrano > 0 then
              print("------- [" .. od .. "," .. stihovi .. "] ---")
              print((table.concat(izabrano, "\n")):gsub("%[(.-)%]", uredi_tekst_u_zagradama))
            else
              print("🚧 У тексту одломка '" .. od .. "' нису пронађени стихови: " .. stihovi)
            end
          else
            print("🚧 Неважећи унос стихова: '" .. stihovi .. "'")
          end
        else
          print("------- [" .. od .. "] ---")
          print(tekst:gsub("%[(.-)%]", uredi_tekst_u_zagradama))
        end
      end
    end
  end
  prvi_put = false
end