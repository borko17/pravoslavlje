
-- 01
print("📥 Преузимање Светог Писма...")

local handle = io.popen(
  'curl -s -D - https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/sveto_pismo.json')

if not handle then
  print("🚫 Грешка: Није могуће покренути 'curl'.")
  return
end

local response = handle:read("*a")
handle:close()

if not response or response == "" then
  print("🚫 Грешка: Није могуће преузети Свето Писмо. Провјерите интернет конекцију.")
  return
end

local header, body = response:match("(.-\r?\n\r?\n)(.*)")
if not body then
  header, body = response:match("(.-\n\n)(.*)")
end

local etag = header:match("[Ee][Tt]ag:%s*([^\r\n]+)")

local velicina_bajtova = #body
local velicina_MB = velicina_bajtova / (1024 * 1024)
local velicina_zaokruzena = math.floor(velicina_MB * 100) / 100

print("🏁 Преузето " .. velicina_zaokruzena .. " MB")
---
-- ✅ Провера верзије скрипте и JSON-а
-- 🔄 Преузми скрипту ради провере нове верзије
local handle_ver = io.popen('curl -s https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/lua/sp.lua')
if not handle_ver then
  print("⚠️ Грешка при преузимању скрипте за проверу верзије.")
  return
end

local skript_body = handle_ver:read("*a")
handle_ver:close()

local nova_verzija = skript_body:match('skript_verzija%s*=%s*"([^"]+)"')
local nova_stajenovo = skript_body:match('json_stajenovo%s*=%s*"([^"]+)"')


local json_verzija = body:match('"сп"%s*:%s*"(.-)"')
local json_stajenovo = body:match('"ново"%s*:%s*"(.-)"')

local skript_verzija = "1.0.8"
local skript_novo = "ништа ново"
local github_link = "https://raw.githubusercontent.com/borko17/pravoslavlje/refs/heads/main/lua/ps.lua"
-- 02

local function latinica_u_cirilicu(s)
  -- Ako je unos tačno "plj" ili počinje sa "plj" i posle sledi broj, ne menjaj "lj" u "љ"
  if not (s == "plj" or s:match("^plj%d") or s == "poslj" or s:match("^poslj%d")) then
    s = s:gsub("lj", "љ")
end
  s = s:gsub("nj", "њ")
  s = s:gsub("dž", "џ")
  local mapa = {
["č"]="ч", ["ć"]="ћ", ["š"]="ш", ["ž"]="ж", ["đ"]="ђ", ["a"]="а", ["b"]="б", ["v"]="в", ["g"]="г", ["d"]="д", ["e"]="е", ["z"]="з", ["i"]="и", ["j"]="ј", ["k"]="к", ["l"]="л", ["m"]="м", ["n"]="н", ["o"]="о", ["p"]="п", ["r"]="р", ["s"]="с", ["t"]="т", ["u"]="у", ["f"]="ф", ["h"]="х", ["c"]="ц",
  }
  return s:lower():gsub("[%z\1-\127\194-\244][\128-\191]*", function(c)
    if c:match("%d") then return c end
    return mapa[c] or c
  end)
end

-- 03
local function uredi_tekst_u_zagradama(sadrzaj)
  sadrzaj = sadrzaj:gsub(":", ",") -- замени ':' са ','
  sadrzaj = sadrzaj:gsub("%s*;%s*", "; "):gsub("[^;]%s+", function(r)
    if r:sub(1,1) ~= ";" then return r:sub(1,1) end
  end):gsub("; %s+", "; "):lower()
  if sadrzaj:match("^%d+$") then
    return "[" .. sadrzaj .. "]"
  else
    return "\n [" .. sadrzaj .. "]"
  end
end

-- 04
local alias_map = {
  ["мтзач1"] = "мт1,1-17",
  ["нед3"] = "__ispisi_poruku"
}

-- 05
local knjige_sa_jednom_glavom = {
  ["авд"] = true, ["послј"] = true, ["флм"] = true,
  ["2јн"] = true, ["3јн"] = true, ["јуд"] = true
}

-- 06
local function safe_insert(t, val)
  local tip = type(val)
  if tip ~= "string" and tip ~= "number" and tip ~= "table" then return end
  table.insert(t, val)
end

-- 07
local function utf8_char_at(s, i)
  local c = s:byte(i)
  if not c then return nil end
  if c < 0x80 then return s:sub(i,i), 1
  elseif c < 0xE0 then return s:sub(i,i+1), 2
  elseif c < 0xF0 then return s:sub(i,i+2), 3
  elseif c < 0xF8 then return s:sub(i,i+3), 4
  else return nil end
end

-- 08
local function je_cifra(karakter)
  return karakter:match("%d") ~= nil
end

-- 09
local function je_slovo(karakter)
  return karakter:match("[%aА-Яа-яЈјЉЊЋЏ]") ~= nil
end

-- 10
local function broj_sa_imenicom(broj, jednina, dvojina, mnozina)
  local mod10 = broj % 10
  local mod100 = broj % 100

  if mod10 == 1 and mod100 ~= 11 then
    return broj .. " " .. jednina
  elseif mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14) then
    return broj .. " " .. dvojina
  else
    return broj .. " " .. mnozina
  end
end

-- 11
local function random_element(tbl)
  local keys = {}
  for k in pairs(tbl) do table.insert(keys, k) end
  return keys[math.random(#keys)]
end

-- 12
local function izvuci_pocetak_knjige(deo)
  local i, len, rezultat = 1, #deo, ""
  while i <= len do
    local c = deo:sub(i,i)
    if je_cifra(c) then
      rezultat = rezultat .. c
      i = i + 1
    else break end
  end
  while i <= len do
    local char, char_len = utf8_char_at(deo, i)
    if not char then break end
    if je_slovo(char) then
      rezultat = rezultat .. char
      i = i + char_len
    else break end
  end
  return rezultat
end

-- 13
local function prosiri_alias(ulaz)
  local rezultat, poslednja_knjiga = {}, nil
  for deo in ulaz:gmatch("[^;%s]+") do
    local pocetak_knjige = izvuci_pocetak_knjige(deo)
    local ostatak = deo:sub(#pocetak_knjige + 1)
    local knjiga = latinica_u_cirilicu(pocetak_knjige)

    -- Ако је књига са једном главом
    if knjige_sa_jednom_glavom[knjiga] then
  if ostatak == "" then
    table.insert(rezultat, knjiga .. "1")
  elseif ostatak:match("^%d") then
    table.insert(rezultat, knjiga .. "," .. ostatak)
  else
    table.insert(rezultat, knjiga .. ostatak)
  end
else
     if pocetak_knjige ~= "" and pocetak_knjige:match("[%aА-Яа-яЈјЉЊЋЏ]") then
        poslednja_knjiga = knjiga
        table.insert(rezultat, knjiga .. ostatak)
else
     if poslednja_knjiga then
          table.insert(rezultat, poslednja_knjiga .. deo)
     else
          table.insert(rezultat, deo)
        end
      end
    end
  end
  return rezultat
end

-- 14
local function prosiri_opseg(deo)
    local rezultat = {}
    local knjiga, prva_glava, poslednja_glava = deo:match("^(%a+)(%d+)%-(%d+)$")
    if knjiga and prva_glava and poslednja_glava then
        for i = tonumber(prva_glava), tonumber(poslednja_glava) do
            table.insert(rezultat, knjiga .. i)
        end
        return rezultat
    end
    
    local od, do_ = deo:match("^(%d+)%-(%d+)$")
    if od and do_ then
        for i = tonumber(od), tonumber(do_) do
            table.insert(rezultat, tostring(i))
        end
    else
        table.insert(rezultat, deo)
    end
    return rezultat
end

-- 15
local function izdvoji_stihove(stihovi_str)
  local stihovi = {}
  for deo in stihovi_str:gmatch("[^,]+") do
    local od, do_ = deo:match("^(%d+)%-(%d+)$")
    if od and do_ then
      for i = tonumber(od), tonumber(do_) do 
        stihovi[i] = true 
      end
    else
      local n = tonumber(deo)
      if n then 
        stihovi[n] = true 
      end
    end
  end
  return stihovi
end

-- 16
print("\n📜 СВЕТО ПИСМО 📜")
print("- Унеси скраћеницу из Светог Писма\n- унеси 'с' за садржај или 'п' за помоћ\n- притисни Ентер за излаз")
print("Скрипта подржава и уносе на латиници")

-- 17
while true do
  io.write("> ")
  local unos = input()
  if not unos or unos == "" then break end
  print("---------------------------------\nунос: " .. unos .. "\n---------------------------------")

-- 18
local novi_unos
if unos:lower():match("^п,") or unos:lower():match("^p,") then
  novi_unos = latinica_u_cirilicu(unos)
else
  local delovi = {}
  for deo in unos:gmatch("[^;%s]+") do
    deo = deo:gsub("^[†*§%.,!\"'%-\\%[%]]+", ""):gsub("[†*§%.,!\"'%-\\%[%]]+$", "")
    -- First expand any ranges in the part
    local prosireni = prosiri_opseg(deo)
    for _, p in ipairs(prosireni) do
      table.insert(delovi, p)
    end
  end
  local ociscen_unos = table.concat(delovi, ";")
  novi_unos = latinica_u_cirilicu(ociscen_unos)
end

-- tekst
if novi_unos == "v" or novi_unos == "в" then
    print("\n== Свето Писмо ==")
    print("Верзија Светог Писма: " .. json_verzija)
    print("Шта је ново: " .. json_stajenovo)
    
    print("\n== Скрипта ==")
print("Верзија скрипте: " .. skript_verzija)
if nova_verzija then
  if nova_verzija ~= skript_verzija then
    print("⚠️ Скрипта није ажурна.")
    print("Последња верзија: " .. nova_verzija)
    print("\n🔗 Преузми нову верзију са:")
    print(github_link)
  else
    print("✔️ Скрипта је ажурна.")
  end
else
  print("ℹ️ Није могуће одредити последњу верзију скрипте са GitHub-а.")
end

  print("\n== lua ==")
    print("Тренутно користите lua верзију:\n" .. _VERSION .."\n\nСкрипта је тестирана на:\nLuaj-jse 3.0.1\nYantra CLI Launcher Pro")
    goto continue
end
-- testend

-- 19
-- 📜 Насумичан стих: ако је 'r' или 'р'
if novi_unos == "n" or novi_unos == "н" then
  local odlomci = {}
  for odlomak, tekst in body:gmatch('"(.-)"%s*:%s*"([^"]-)"') do
    if tekst:match("\n%d+%.") then -- само ако има бројеве стихова
      table.insert(odlomci, {odlomak=odlomak, tekst=tekst})
    end
  end
  
  if #odlomci == 0 then
    print("🚧 Није пронађен ниједан валидан одломак.")
    goto continue
  end
  
  local nasumicni = odlomci[math.random(#odlomci)]
  local linije = {}
  for lin in nasumicni.tekst:gmatch("[^\r\n]+") do
    if lin:match("^%d+%.") then
      table.insert(linije, lin)
    end
  end

  if #linije == 0 then
    print("🚧 Одломак нема стихове.")
    goto continue
  end

  -- Насумичан почетни индекс тако да има места за 3 узастопна стиха
  local max_start = math.max(1, #linije - 2)
  local start_index = math.random(max_start)

  print("---------------------------------\n🎲 Насумични стихови: [" .. nasumicni.odlomak .. "]\n---------------------------------")
  for i = start_index, math.min(start_index + 2, #linije) do
    local stih = linije[i]
    print(stih:gsub("%[(.-)%]", uredi_tekst_u_zagradama))
  end
  goto continue
end


-- 📖 Претрага више речи или фразе
-- Dodaj listu odlomaka koje želimo izuzeti iz pretrage
local izuzeti_odlomci = {
    ["с"] = true,  -- изузимам садржај
    ["п"] = true   -- изузимам помоћ
}

if novi_unos:match("^п[,#]") then
    local is_phrase_search = novi_unos:match("^п,#") ~= nil
    local deo = novi_unos:sub(is_phrase_search and 4 or 3)
    print("🔍 Претрага је у току...")
    if not deo or deo:match("^%s*$") then
        print("⚠️ Унесите бар једну ријеч или фразу за претрагу.")
        goto continue
    end

    local rezultati = {}
    local ukupan_broj = 0

    -- Logika za pretragu
    local search_terms = {}
    
    if is_phrase_search then
        -- Za frazno pretraživanje, uzimamo celu frazu nakon p,# i uklanjamo # ako postoji na početku
        local fraza = latinica_u_cirilicu(deo):lower():gsub("^%s*#", ""):gsub("^%s*(.-)%s*$", "%1")
        if fraza ~= "" then
            table.insert(search_terms, fraza)
        end
    else
        -- Za normalno pretraživanje, delimo po zarezima
        for rec in deo:gmatch("([^,]+)") do
            local cir_rec = latinica_u_cirilicu(rec):lower():gsub("^%s*(.-)%s*$", "%1")
            if cir_rec ~= "" then 
                table.insert(search_terms, cir_rec)
            end
        end
    end

    -- Остатак кода остаје исти...
    -- [исти код као претходно]

    if #search_terms == 0 then
        print("⚠️ Нисте унели ниједну важећу ријеч или фразу.")
        goto continue
    end

    for odlomak, tekst in body:gmatch('"(.-)"%s*:%s*"([^"]-)"') do
        if not izuzeti_odlomci[odlomak] then
            local current_verse = nil
            local verse_content = {}
            
            -- Функција за проверу стиха
            local function check_verse()
                if current_verse and #verse_content > 0 then
                    local full_verse = table.concat(verse_content, " ")
                    local verse_clean = latinica_u_cirilicu(full_verse):lower()
                    local sve_prisutne = true
                    
                    if is_phrase_search then
                        -- Za frazno pretraživanje, tražimo tačno podudaranje
                        if not verse_clean:find(search_terms[1], 1, true) then
                            sve_prisutne = false
                        end
                    else
                        -- Normalno pretraživanje - sve reči moraju biti prisutne
                        for _, trazena in ipairs(search_terms) do
                            if not verse_clean:find(trazena, 1, true) then
                                sve_prisutne = false
                                break
                            end
                        end
                    end
                    
                    if sve_prisutne then
                        ukupan_broj = ukupan_broj + 1
                        table.insert(rezultati, {
                            odlomak = odlomak,
                            broj_stiha = current_verse,
                            tekst = full_verse
                        })
                    end
                end
            end

            for lin in tekst:gmatch("[^\r\n]+") do
                -- Провера да ли ред почиње бројем
                local broj = lin:match("^(%d+)")
                if broj then
                    -- Провери претходни стих пре него што почнеш нови
                    check_verse()
                    -- Започни нови стих
                    current_verse = broj
                    verse_content = {lin}
                else
                    -- Додај ред текућем стиху
                    if current_verse then
                        table.insert(verse_content, lin)
                    end
                end
            end
            -- Провери последњи стих
            check_verse()
        end
    end

    if ukupan_broj == 0 then
        if is_phrase_search then
            print("🚫 Није пронађен ниједан стих са фразом: '" .. search_terms[1] .. "'")
        else
            print("🚫 Није пронађен ниједан стих са ријечима: '" .. table.concat(search_terms, "', '") .. "'")
        end
    else
        if is_phrase_search then
            print("---------------------------------\nПронађено укупно " .. broj_sa_imenicom(ukupan_broj, "стих", "стиха", "стихова") .. " где се налази фраза: '" .. search_terms[1] .. "'\n---------------------------------")
        else
            print("---------------------------------\nПронађено укупно " .. broj_sa_imenicom(ukupan_broj, "стих", "стиха", "стихова") .. " где се налазе ријечи: '" .. table.concat(search_terms, "', '") .. "'\n---------------------------------")
        end
        os.execute("sleep 2") -- za Linux/macOS
        for _, r in ipairs(rezultati) do
            print("[" .. r.odlomak .. "," .. r.broj_stiha .. "] " .. r.tekst:gsub("%[(.-)%]", uredi_tekst_u_zagradama))
        end
    end

    goto continue
end

-- 21
  -- Специјални случај: ако је 'с' или 'п', прикажи директно садржај из JSON-а

local specijalni_tekst = body:match('"' .. novi_unos .. '"%s*:%s*"([^"]-)"')
if specijalni_tekst then
  print("------- [" .. novi_unos .. "] -------")
  print(specijalni_tekst:gsub("%[(.-)%]", uredi_tekst_u_zagradama))
  goto continue
end

  if alias_map[novi_unos] then
    novi_unos = alias_map[novi_unos]
  end

-- 04a
if novi_unos == "__ispisi_poruku" then
  print("нед3 - [рим5,1-10; мт6,20-33]")
  goto continue
end


-- 22
-- Специјални случај: ако је 'с,', приказати садржај
if novi_unos:match("^с,") then
  local knjiga = novi_unos:sub(4)
  if knjige_sa_jednom_glavom[knjiga] then
    local tekst = nil
    for odlomak, t in body:gmatch('"(.-)"%s*:%s*"([^"]-)"') do
      if odlomak == knjiga then
        tekst = t
        break
      end
    end

    if tekst then
      print("---------------------------------\n📖 Садржај за књигу: " .. knjiga .. "\n---------------------------------")
      -- Count verses
      local broj_stihova = 0
      for lin in tekst:gmatch("[^\r\n]+") do
        if lin:match("^%d+%.") then
          broj_stihova = broj_stihova + 1
        end
      end
      local naslov = tekst:match("Глава%s+1%.%s*(.-)\n") or tekst:match("Наслов%s*:%s*(.-)\n") or "Нема наслова"
      print("Глава 1. (" .. broj_stihova .. " стихова)\n" .. naslov)
    else
      print("🚧 Није пронађен садржај за књигу: " .. knjiga)
    end

  else
    local pronadjeno = false
    for odlomak, tekst in body:gmatch('"(.-)"%s*:%s*"([^"]-)"') do
      if odlomak:lower():match("^" .. knjiga:lower() .. "%d+$") then
        local broj = odlomak:match("%d+$")
        -- Count verses for this chapter
        local broj_stihova = 0
        for lin in tekst:gmatch("[^\r\n]+") do
          if lin:match("^%d+%.") then
            broj_stihova = broj_stihova + 1
          end
        end
        local naslov
        if knjiga == "пс" then
          naslov = tekst:match("Псалам%s+" .. broj .. "%.%s*\n(.-)\n")
        else
          naslov = tekst:match("Глава%s+" .. broj .. "%.%s*\n(.-)\n")
        end
        if naslov then
          if not pronadjeno then
            print("---------------------------------\n📖 Садржај за књигу: " .. knjiga .. "\n---------------------------------")
          end
          local oznaka = (knjiga == "пс" and "Псалам" or "Глава")
          print(oznaka .. " " .. broj .. ". (" .. broj_sa_imenicom(broj_stihova, "стих", "стиха", "стихова") .. ")\n" .. naslov)
          pronadjeno = true
        end
      end
    end
    if not pronadjeno then
      print("🚧 Није пронађен садржај за књигу: " .. knjiga)
    end
  end

  goto continue
end

-- 23
  -- 📘 Приказ свих глава у књизи ако унос није конкретан стих
  
  if not novi_unos:find(",") and not novi_unos:find("%-") and not novi_unos:match("%d$") and #novi_unos > 1 then
    local knjiga = novi_unos
    print("---------------------------------\n📘 Све главе књиге: " .. knjiga .. "\n---------------------------------")
    local found = false
    for odlomak, tekst in body:gmatch('"(.-)"%s*:%s*"([^"]-)"') do
      if odlomak:lower():match("^" .. knjiga:lower() .. "%d+$") then
       
        print("------- [" .. odlomak .. "] ---\n" .. tekst:gsub("%[(.-)%]", uredi_tekst_u_zagradama))
        found = true
      end
    end
    if not found then
      print("🚧 Није пронађена књига: " .. knjiga)
    end
    goto continue
  end


-- 24
  local svi_aliasi = prosiri_alias(novi_unos)
  local svi_odlomci = {}

  for _, deo in ipairs(svi_aliasi) do
    local knj, stihovi_str = deo:match("^(.-),(.+)$")
    if knj then
      local prosireni = prosiri_opseg(knj)
      for _, odlomak in ipairs(prosireni) do
        safe_insert(svi_odlomci, {odlomak=odlomak, stihovi=stihovi_str})
      end
    else
      local prosireni = prosiri_opseg(deo)
      for _, odlomak in ipairs(prosireni) do
        safe_insert(svi_odlomci, {odlomak=odlomak, stihovi=nil})
      end
    end
  end

  for _, podaci in ipairs(svi_odlomci) do
  local tekst = body:match('"' .. podaci.odlomak .. '"%s*:%s*"([^"]-)"')
  if tekst then
    local linije = {}
    for lin in tekst:gmatch("[^\r\n]+") do
      table.insert(linije, lin)
    end

    if podaci.stihovi then
      local ciljani = izdvoji_stihove(podaci.stihovi)
      local izabrano = {}

      local i = 1
      while i <= #linije do
        local broj = tonumber(linije[i]:match("^(%d+)%."))
        if broj and ciljani[broj] then
          local blok = { linije[i] }
          i = i + 1
          while i <= #linije and not linije[i]:match("^%d+%.") do
            table.insert(blok, linije[i])
            i = i + 1
          end
          table.insert(izabrano, table.concat(blok, "\n"))
        else
          i = i + 1
        end
      end

-- 25
if #izabrano > 0 then
  print("------- [" .. podaci.odlomak .. "," .. podaci.stihovi .. "] ---")
  print((table.concat(izabrano, "\n")):gsub("%[(.-)%]", uredi_tekst_u_zagradama))
else
  print("🚧 Нема " .. podaci.stihovi .. ". стиха у одломку " .. podaci.odlomak)
  
  local broj_stihova = 0
  for _, lin in ipairs(linije) do
    if lin:match("^%d+%.") then
      broj_stihova = broj_stihova + 1
    end
  end

  print("📘 Одломак " .. podaci.odlomak .. " има " .. broj_sa_imenicom(broj_stihova, "стих", "стиха", "стихова") .. ".")
end

    else
      print("------- [" .. podaci.odlomak .. "] ---")
      print(tekst:gsub("%[(.-)%]", uredi_tekst_u_zagradama))
    end
  else

  print("🚧 Није пронађен одломак: " .. podaci.odlomak)
  local knjiga = podaci.o
