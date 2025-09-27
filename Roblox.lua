local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- ===== WEBHOOKS =====
local WEBHOOK_URL = "https://discord.com/api/webhooks/1418388829160607778/tLZjaLoSwiEJ5RpiJyIVxlSYtUfOXCXuw4ips0hNBuNRsK-Ukrch4NXxubi-o8K3-hoR"
local SPECIAL_WEBHOOK_URL = "https://discord.com/api/webhooks/1418386817820004403/-E0obGTbnxTFAfNTY_M06Ds05e1QEbQWtn3ROym1DETpE_Seo4sKnv--su-6oneCGaEu"

-- ===== CONFIGURAÇÃO DE TROCA DE SERVIDOR =====
local SERVER_SWITCH_INTERVAL = 3 -- segundos
local PLACE_ID = game.PlaceId -- ID do jogo atual

-- ========= FORMATAÇÃO =========
local function fmtShort(n)
    if not n then return "0" end
    local a = math.abs(n)
    if a >= 1e12 then
        local s = string.format("%.2fT", n/1e12)
        return (s:gsub("%.00",""))
    elseif a >= 1e9 then
        local s = string.format("%.1fB", n/1e9)
        return s:gsub("%.0B","B")
    elseif a >= 1e6 then
        local s = string.format("%.1fM", n/1e6)
        return s:gsub("%.0M","M")
    elseif a >= 1e3 then
        return string.format("%.0fk", n/1e3)
    else
        return tostring(n)
    end
end
local function money(n) return "$"..fmtShort(n) end
local function moneyPerSec(n) return "$"..fmtShort(n).."/s" end

-- ========= BASE DE DADOS =========
local DB = {
  ["Agarrini la Palini"]={price=80000000,gen=425000},
  ["Alessio"]={price=17500000,gen=85000},
  ["Avocadini Antilopini"]={price=17500,gen=115},
  ["Avocadini Guffo"]={price=35000,gen=225},
  ["Avocadorilla"]={price=2000000,gen=7000},
  ["Ballerina Cappuccina"]={price=100000,gen=500},
  ["Ballerino Lololo"]={price=35000000,gen=200000},
  ["Bambini Crostini"]={price=22500,gen=135},
  ["Bananita Dolphinita"]={price=25000,gen=150},
  ["Bandito Bobritto"]={price=4500,gen=35},
  ["Bisonte Giuppitere"]={price=75000000,gen=300000},
  ["Blackhole Goat"]={price=75000000,gen=400000},
  ["Blueberrinni Octopusini"]={price=250000,gen=1000},
  ["Bombardini Tortinii"]={price=50000000,gen=225000},
  ["Bombardiro Crocodilo"]={price=500000,gen=2500},
  ["Bombombini Gusini"]={price=1000000,gen=5000},
  ["Boneca Ambalabu"]={price=5000,gen=40},
  ["Brr Brr Patapim"]={price=15000,gen=100},
  ["Brr es Teh Patipum"]={price=40000000,gen=225000},
  ["Brri Brri Bicus Dicus Bombicus"]={price=30000,gen=175},
  ["Bulbito Bandito Traktorito"]={price=35000000,gen=205000},
  ["Cacto Hipopotamo"]={price=6500,gen=50},
  ["Cappuccino Assassino"]={price=10000,gen=75},
  ["Carloo"]={price=4500000,gen=13500},
  ["Carrotini Brainini"]={price=4750000,gen=15000},
  ["Cavallo Virtuoso"]={price=2500000,gen=7500},
  ["Chef Crabracadabra"]={price=150000,gen=600},
  ["Chicleteira Bicicleteira"]={price=750000000,gen=3500000},
  ["Chimpanzini Bananini"]={price=50000,gen=300},
  ["Cocofanto Elefanto"]={price=5000000,gen=17500},
  ["Cocosini Mama"]={price=285000,gen=1200},
  ["Dul Dul Dul"]={price=150000000,gen=375000},
  ["Espresso Signora"]={price=25000000,gen=70000},
  ["Esok Sekolah"]={price=3500000000,gen=30000000},
  ["Fluriflura"]={price=750,gen=7},
  ["Frigo Camelo"]={price=350000,gen=1400},
  ["Garama and Madundung"]={price=10000000000,gen=50000000},
  ["Ganganzelli Trulala"]={price=3750000,gen=9000},
  ["Gangster Footera"]={price=4000,gen=30},
  ["Gattatino Nyanino"]={price=7500000,gen=35000},
  ["Girafa Celestre"]={price=7500000,gen=20000},
  ["Glorbo Fruttodrillo"]={price=200000,gen=750},
  ["Gorillo Watermelondrillo"]={price=3000000,gen=8000},
  ["Graipuss Medussi"]={price=250000000,gen=1000000},
  ["Guerriro Digitale"]={price=120000000,gen=550000},
  ["Job Job Job Sahur"]={price=175000000,gen=700000},
  ["Karkerkar Kurkur"]={price=100000000,gen=300000},
  ["Ketchuru and Musturu"]={price=7500000000,gen=42500000},
  ["Ketupat Kepat"]={price=5000000000,gen=35000000},
  ["La Grande Combinasion"]={price=1000000000,gen=10000000},
  ["La Supreme Combinasion"]={price=7000000000,gen=40000000},
  ["La Vacca Saturno Saturnita"]={price=50000000,gen=300000},
  ["Lerulerulerule"]={price=3500000,gen=8750},
  ["Lionel Cactuseli"]={price=175000,gen=650},
  ["Lirilì Larilà"]={price=250,gen=3},
  ["Los Bombinitos"]={price=42500000,gen=220000},
  ["Los Combinasionas"]={price=2000000000,gen=15000000},
  ["Los Crocodillitos"]={price=12500000,gen=55000},
  ["Los Hotspotsitos"]={price=3000000000,gen=20000000},
  ["Los Matteos"]={price=100000000,gen=300000},
  ["Los Orcalitos"]={price=45000000,gen=235000},
  ["Los Spyderinis"]={price=90000000,gen=425000},
  ["Las Tralaleritas"]={price=150000000,gen=650000},
  ["Las Vaquitas Saturnitas"]={price=200000000,gen=750000},
  ["Lucky Block (Admin Lucky Block)"]={price=100000000,gen=0},
  ["Lucky Block (Brainrot God Lucky Block)"]={price=25000000,gen=0},
  ["Lucky Block (Mythic Lucky Block)"]={price=2500000,gen=0},
  ["Lucky Block (Secret Lucky Block)"]={price=750000000,gen=0},
  ["Mastodontico Telepiedone"]={price=47500000,gen=275000},
  ["Matteo"]={price=10000000,gen=50000},
  ["Noobini Pizzanini"]={price=25,gen=1},
  ["Nooo My Hotspot"]={price=500000000,gen=1500000},
  ["Nuclearo Dinossauro"]={price=2500000000,gen=15000000},
  ["Odin Din Din Dun"]={price=15000000,gen=75000},
  ["Orangutini Ananassini"]={price=400000,gen=1750},
  ["Pandaccini Bananini"]={price=300000,gen=1250},
  ["Perochello Lemonchello"]={price=27500,gen=160},
  ["Penguino Cocosino"]={price=45000,gen=300},
  ["Piccione Macchina"]={price=40000000,gen=225000},
  ["Pi Pi Watermelon"]={price=315000,gen=1300},
  ["Pipi Avocado"]={price=9500,gen=70},
  ["Pipi Corni"]={price=1750,gen=14},
  ["Pipi Kiwi"]={price=1500,gen=13},
  ["Pipi Potato"]={price=265000,gen=1100},
  ["Pot Hotspot"]={price=600000000,gen=2500000},
  ["Quivioli Ameleonni"]={price=225000,gen=900},
  ["Raccooni Jandelini"]={price=1350,gen=12},
  ["Rhino Toasterino"]={price=450000,gen=2150},
  ["Salamino Penguino"]={price=40000,gen=250},
  ["Sammyni Spyderini"]={price=100000000,gen=325000},
  ["Sigma Boy"]={price=325000,gen=1350},
  ["Spaghetti Tualetti"]={price=15000000000,gen=60000000},
  ["Spioniro Golubiro"]={price=750000,gen=3500},
  ["Strawberrelli Flamingelli"]={price=275000,gen=1150},
  ["Strawberry Elephant"]={price=500000000000,gen=250000000},
  ["Svinina Bombardino"]={price=1250,gen=10},
  ["Talpa Di Fero"]={price=1000,gen=9},
  ["Tartaruga Cisterna"]={price=45000000,gen=250000},
  ["Te Te Te Sahur"]={price=4000000,gen=9500},
  ["Ti Ti Ti Sahur"]={price=37500,gen=225},
  ["Tigrilini Watermelini"]={price=1750000,gen=6500},
  ["Tigroligre Frutonni"]={price=14000000,gen=60000},
  ["Tipi Topi Taco"]={price=20000000,gen=75000},
  ["Tim Cheese"]={price=500,gen=5},
  ["Tob Tobi Tobi"]={price=3250000,gen=8500},
  ["Torrtuginni Dragonfrutini"]={price=125000000,gen=350000},
  ["Tracoducotulu Delapeladustuz"]={price=4250000,gen=12000},
  ["Tralalero Tralala"]={price=10000000,gen=50000},
  ["Tralalita Tralala"]={price=20000000,gen=100000},
  ["Trenostruzzo Turbo 3000"]={price=25000000,gen=150000},
  ["Tric Trac Baraboom"]={price=9000,gen=65},
  ["Trippi Troppi"]={price=2000,gen=15},
  ["Trippi Troppi Troppa Trippa"]={price=30000000,gen=175000},
  ["Trulimero Trulicina"]={price=20000,gen=125},
  ["Tukanno Bananno"]={price=22500000,gen=100000},
  ["Tung Tung Tung Sahur"]={price=3000,gen=25},
  ["Unclito Samito"]={price=20000000,gen=75000},
  ["Urubini Flamenguini"]={price=30000000,gen=150000},
  ["Zibra Zubra Zibralini"]={price=1500000,gen=6000},
}

-- aliases para variações que você usa
local ALIAS = {
  ["Lirill Larila"] = "Lirilì Larilà",
  ["Lion el Cactuseli"] = "Lionel Cactuseli",
  ["Ch(ic)leteira Bicicleteira"] = "Chicleteira Bicicleteira",
}
for short,long in pairs(ALIAS) do if DB[long] then DB[short]=DB[long] end end

-- ========= UTIL =========
local function getOwner(plot)
    local success, result = pcall(function()
        local ov = plot:FindFirstChild("Owner", true)
        if ov and ov:IsA("ObjectValue") and ov.Value and ov.Value:IsA("Player") then return ov.Value end
        
        local uid = plot:GetAttribute("OwnerUserId")
        if uid then return Players:GetPlayerByUserId(uid) end
        
        local iv = plot:FindFirstChild("OwnerUserId", true)
        if iv and iv:IsA("IntValue") then return Players:GetPlayerByUserId(iv.Value) end
        
        local sv = plot:FindFirstChild("OwnerName", true)
        if sv and sv:IsA("StringValue") then
            for _,p in ipairs(Players:GetPlayers()) do 
                if p.Name == sv.Value then return p end 
            end
        end
        return nil
    end)
    return success and result or nil
end

local function countAnimalsInPlot(plot)
    local counts, topName, topPrice = {}, nil, -1
    
    local success, descendants = pcall(function()
        return plot:GetDescendants()
    end)
    
    if not success then return counts, topName, topPrice end
    
    for _,inst in ipairs(descendants) do
        if inst:IsA("Model") then
            local name = inst.Name
            if DB[name] then
                counts[name] = (counts[name] or 0) + 1
                local p = DB[name].price or 0
                if p > topPrice then topPrice, topName = p, name end
            else
                for short, long in pairs(ALIAS) do
                    if name == short then
                        counts[long] = (counts[long] or 0) + 1
                        local p = DB[long].price or 0
                        if p > topPrice then topPrice, topName = p, long end
                        break
                    end
                end
            end
        end
    end
    return counts, topName, topPrice
end

-- ====== HELPER: envio robusto da webhook ======
local function _tryWebhookSend(jsonBody, webhookUrl)
    local success = false
    
    -- Tentar diferentes métodos de requisição HTTP
    local requestFunctions = {
        function() return syn and syn.request end,
        function() return http_request end,
        function() return request end,
        function() return http and http.request end
    }
    
    for _, getRequestFunc in ipairs(requestFunctions) do
        local req = getRequestFunc()
        if req then
            local ok, res = pcall(function()
                return req({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = jsonBody
                })
            end)
            
            if ok and res and (res.StatusCode or res.Status) and tonumber(res.StatusCode or res.Status) < 400 then
                success = true
                break
            end
        end
    end
    
    return success
end

-- ===== FUNÇÃO PARA OBTER OS 5 BRAINROTS COM MAIOR GERAÇÃO =====
local function getTop5Brainrots(serverCounts)
    local brainrotList = {}
    
    -- Converter a tabela de contagens em uma lista
    for name, count in pairs(serverCounts) do
        local info = DB[name]
        if info and info.gen and info.gen > 0 then
            table.insert(brainrotList, {
                name = name,
                count = count,
                gen = info.gen,
                totalGen = info.gen * count,
                price = info.price
            })
        end
    end
    
    -- Ordenar por geração total (gen * count)
    table.sort(brainrotList, function(a, b)
        return a.totalGen > b.totalGen
    end)
    
    -- Retornar os top 5
    local top5 = {}
    for i = 1, math.min(5, #brainrotList) do
        table.insert(top5, brainrotList[i])
    end
    
    return top5
end

-- ===== WEBHOOK NORMAL =====
local function sendWebhookNormal(serverCounts, totalPriceAll, totalGenAll)
    -- Filtrar brainrots com gen < 10.000.000 para o webhook normal
    local filteredCounts = {}
    for name, count in pairs(serverCounts) do
        local info = DB[name]
        if info and info.gen and info.gen < 10000000 then
            filteredCounts[name] = count
        end
    end
    
    local top5Brainrots = getTop5Brainrots(filteredCounts)
    
    local lines = {}
    for i, brainrot in ipairs(top5Brainrots) do
        table.insert(lines, string.format("%d. %s — %s (x%d) | Total: %s/s", 
            i, brainrot.name, moneyPerSec(brainrot.gen), brainrot.count, moneyPerSec(brainrot.totalGen)))
    end
    
    if #lines == 0 then 
        table.insert(lines, "Nenhum brainrot encontrado.") 
    end

    local embed = {
        title = "🧠 RELATÓRIO DE SERVIDOR",
        description = string.format("**JobId:**\n```\n%s\n```", game.JobId),
        color = 5793266,
        fields = {
            {
                name = "📊 Info do Servidor",
                value = string.format("Jogadores: %d/%d\nPlaceId: `%d`",
                    #Players:GetPlayers(), Players.MaxPlayers, game.PlaceId),
                inline = false
            },
            {
                name = "💰 Totais do Servidor",
                value = string.format("Preço total: %s\nGeração total: %s",
                    money(totalPriceAll), moneyPerSec(totalGenAll)),
                inline = false
            },
            {
                name = "🏆 Top 5 Brainrots (maior geração total)",
                value = table.concat(lines, "\n"),
                inline = false
            }
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    local payload = {content = "📡 Relatório automático", embeds = {embed}}
    local success, json = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    
    if success then
        _tryWebhookSend(json, WEBHOOK_URL)
    end
    
    -- Log local
    print("🏆 TOP 5 BRAINROTS DO SERVIDOR (gen < 10M/s):")
    for i, brainrot in ipairs(top5Brainrots) do
        print(string.format("%d. %s: %s/s cada (x%d) | Total: %s/s", 
            i, brainrot.name, moneyPerSec(brainrot.gen), brainrot.count, moneyPerSec(brainrot.totalGen)))
    end
end

-- ===== WEBHOOK ESPECIAL =====
local function sendSpecialWebhook(ultraHighGenBrainrots, totalHighGenPrice, totalHighGenGen)
    if #ultraHighGenBrainrots == 0 then return end
    
    -- Obter os 5 brainrots de ultra alta geração com maior geração total
    table.sort(ultraHighGenBrainrots, function(a, b)
        return (a.Gen * a.Count) > (b.Gen * b.Count)
    end)
    
    local top5UltraHighGen = {}
    for i = 1, math.min(5, #ultraHighGenBrainrots) do
        table.insert(top5UltraHighGen, ultraHighGenBrainrots[i])
    end
    
    local lines = {}
    for i, brainrot in ipairs(top5UltraHighGen) do
        table.insert(lines, string.format("%d. %s — %s (x%d) | Total: %s/s", 
            i, brainrot.Name, moneyPerSec(brainrot.Gen), brainrot.Count, moneyPerSec(brainrot.Gen * brainrot.Count)))
    end

    local embed = {
        title = "🚨 ULTRA HIGH GEN BRAINROTS ENCONTRADOS!",
        description = string.format("**JobId:** ```%s```\n**Servidor:** %d jogadores\n**Brainrots com ≥10M/s encontrados!**",
            game.JobId, #Players:GetPlayers()),
        color = 16711680,
        fields = {
            {
                name = "🏆 Top 5 Brainrots Ultra High Gen (≥10M/s)",
                value = table.concat(lines, "\n"),
                inline = false
            },
            {
                name = "💰 Totais de Ultra Alta Geração",
                value = string.format("Preço total: %s\nGeração total: %s",
                    money(totalHighGenPrice), moneyPerSec(totalHighGenGen)),
                inline = false
            }
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        footer = {
            text = "⚠️ ALERTA DE ULTRA ALTA GERAÇÃO (≥10M/s)"
        }
    }

    local payload = {
        content = "@everyone 🚨 **ULTRA HIGH GEN BRAINROTS DETECTED!** (≥10M/s) 🚨",
        embeds = {embed}
    }
    
    local success, json = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    
    if success then
        _tryWebhookSend(json, SPECIAL_WEBHOOK_URL)
    end
    
    -- Log local
    print("🚨 ULTRA HIGH GEN BRAINROTS (≥10M/s):")
    for i, brainrot in ipairs(top5UltraHighGen) do
        print(string.format("%d. %s: %s/s cada (x%d) | Total: %s/s", 
            i, brainrot.Name, moneyPerSec(brainrot.Gen), brainrot.Count, moneyPerSec(brainrot.Gen * brainrot.Count)))
    end
end

-- ===== SISTEMA DE TROCA DE SERVIDOR EXTERNO =====
local function switchServer()
    print("🔄 Iniciando troca de servidor usando LK Server Hop...")
    
    -- Carregar e usar o módulo externo de server hop
    local success, errorMsg = pcall(function()
        local module = loadstring(game:HttpGet"https://raw.githubusercontent.com/LeoKholYt/roblox/main/lk_serverhop.lua")()
        module:Teleport(game.PlaceId)
    end)
    
    if not success then
        warn("❌ Falha ao usar LK Server Hop: " .. tostring(errorMsg))
        print("⚠️ Usando método de fallback...")
        
        -- Método de fallback: teleporte aleatório simples
        local fallbackSuccess = pcall(function()
            TeleportService:Teleport(PLACE_ID, Players.LocalPlayer)
        end)
        
        if not fallbackSuccess then
            warn("❌ Falha no método de fallback também.")
        end
    end
end

-- ========= EXECUÇÃO PRINCIPAL =========
local function scanServer()
    print("🔍 Iniciando scan do servidor...")
    
    local success, plotsRoot = pcall(function()
        return Workspace:FindFirstChild("Plots")
    end)
    
    if not success or not plotsRoot then 
        warn("❌ Workspace.Plots não encontrado ou erro ao acessar.")
        return 
    end

    local globalPrice, globalGen = 0, 0
    local ultraHighGenPrice, ultraHighGenGen = 0, 0
    local serverCounts = {}
    local ultraHighGenBrainrots = {}

    local success, plots = pcall(function()
        return plotsRoot:GetChildren()
    end)
    
    if not success then return end
    
    for _,plot in ipairs(plots) do
        if plot:IsA("Model") or plot:IsA("Folder") then
            local owner = getOwner(plot)
            local counts, topName = countAnimalsInPlot(plot)

            local totalQtd, totalPrice, totalGen = 0, 0, 0
            for name,q in pairs(counts) do
                totalQtd += q
                totalPrice += (DB[name] and DB[name].price or 0) * q
                totalGen   += (DB[name] and DB[name].gen or 0) * q
                serverCounts[name] = (serverCounts[name] or 0) + q
                
                local genPerUnit = DB[name] and DB[name].gen or 0
                if genPerUnit >= 10000000 then
                    table.insert(ultraHighGenBrainrots, {
                        Name = name,
                        Count = q,
                        Gen = genPerUnit,
                        Plot = plot.Name,
                        Owner = owner and owner.Name or "Unknown"
                    })
                    ultraHighGenPrice += (DB[name] and DB[name].price or 0) * q
                    ultraHighGenGen += (DB[name] and DB[name].gen or 0) * q
                end
            end
            globalPrice += totalPrice; globalGen += totalGen
        end
    end

    print("📊 Scan concluído!")
    print(("💰 Preço total: %s | Geração total: %s")
        :format(money(globalPrice), moneyPerSec(globalGen)))

    -- Envia webhook especial apenas se houver brainrots ≥ 10M/s
    if #ultraHighGenBrainrots > 0 then
        print("🚨 ULTRA HIGH GEN Brainrots encontrados! (≥10M/s)")
        sendSpecialWebhook(ultraHighGenBrainrots, ultraHighGenPrice, ultraHighGenGen)
    end
    
    -- Sempre envia o webhook normal
    sendWebhookNormal(serverCounts, globalPrice, globalGen)
end

-- Executar o sistema principal
print("✅ Sistema iniciado! Intervalo: " .. SERVER_SWITCH_INTERVAL .. "s")

local function main()
    while true do
        -- Esperar o jogo carregar completamente
        wait(10)
        
        -- Fazer o scan com proteção contra erros
        local success, error = pcall(scanServer)
        if not success then
            warn("❌ Erro durante o scan:", error)
        end
        
        -- Esperar o intervalo
        print("⏰ Aguardando " .. SERVER_SWITCH_INTERVAL .. "s para trocar de servidor...")
        wait(SERVER_SWITCH_INTERVAL)
        
        -- Trocar de servidor
        local switchSuccess, switchError = pcall(switchServer)
        if not switchSuccess then
            warn("❌ Erro ao trocar de servidor:", switchError)
        end
        
        -- Esperar a teleportação completar
        wait(15)
    end
end

-- Iniciar o sistema com proteção
local success, err = pcall(function()
    coroutine.wrap(main)()
end)

if not success then
    warn("❌ Erro crítico ao iniciar o sistema:", err)
end
