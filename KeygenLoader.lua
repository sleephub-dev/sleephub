--[[
    =============================================================================
    SLEEPSHOP - KEYGEN.SH PROFESSIONAL LICENSE LOADER & ANTI-CRACK
    =============================================================================
    Account ID: 456f8308-87a3-49a1-8d76-4603d16403af
    Product ID: ce9090db-b281-4900-a21a-8a1cae28bb0e (Anime Adventures Script)
    =============================================================================
]]

local ACCOUNT_ID = "456f8308-87a3-49a1-8d76-4603d16403af"
local PRODUCT_ID = "ce9090db-b281-4900-a21a-8a1cae28bb0e"
local SCRIPT_NAME = "SleepShop - Anime Adventures [UPD 21]"
local KEY_FILENAME = "sleepshop_key.txt"
-- URL สคริปต์หลักออนไลน์ (กรณีนำไปโฮสต์บน GitHub Raw / Private CDN เช่นเดียวกับ Maru Hub)
local SCRIPT_RAW_URL = "" 

-- =========================================================================
-- 1. ANTI-CRACK & ANTI-TAMPER INTEGRITY CHECKS
-- =========================================================================
local function AntiTamperCheck()
    -- ตรวจสอบว่าฟังก์ชันพื้นฐานไม่ถูก hook เพื่อปลอมแปลงค่า
    if hookfunction or replaceclosure then
        local testFunc = function() return "original_integrity_123" end
        local isHooked = false
        pcall(function()
            if iscclosure and iscclosure(testFunc) then isHooked = true end
        end)
        if isHooked then
            warn("[SECURITY] ตรวจพบการดัดแปลงหน่วยความจำระบบ!")
            return false
        end
    end

    -- ตรวจจับโปรแกรมดักจับรีเควสต์ HttpSpy / SimpleSpy ในหน่วยความจำ
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local pgui = lp and lp:FindFirstChild("PlayerGui")

    local suspiciousGuis = {"HttpSpy", "SimpleSpy", "Dex", "DarkDex", "Hydroxide"}
    for _, name in ipairs(suspiciousGuis) do
        if (CoreGui and CoreGui:FindFirstChild(name)) or (pgui and pgui:FindFirstChild(name)) then
            warn("[SECURITY] ตรวจพบเครื่องมือดักจับข้อมูล (" .. name .. ") กรุณาปิดก่อนใช้งาน!")
            -- ไม่หยุดทำงานกะทันหันแต่จะทำให้ไม่สามารถอ่าน Keygen Payload ได้
        end
    end

    return true
end

-- =========================================================================
-- 2. HARDWARE FINGERPRINT (HWID BINDING)
-- =========================================================================
local function GetHardwareFingerprint()
    local hwid = ""
    pcall(function()
        local rbxAnalytics = game:GetService("RbxAnalyticsService")
        hwid = rbxAnalytics:GetClientId()
    end)
    if not hwid or hwid == "" then
        pcall(function()
            if gethwid then
                hwid = gethwid()
            end
        end)
    end
    if not hwid or hwid == "" then
        hwid = tostring(game:GetService("Players").LocalPlayer.UserId)
    end
    return hwid
end

-- =========================================================================
-- 3. HTTP REQUEST DISPATCHER (รองรับทุก Executor)
-- =========================================================================
local function HttpRequest(options)
    local fn = (syn and syn.request) 
        or (http and http.request) 
        or http_request 
        or request
    if not fn then
        error("[KEYGEN] Executor ของคุณไม่รองรับฟังก์ชันส่ง HTTP Request (request / http_request)")
    end
    return fn(options)
end

-- =========================================================================
-- 4. KEY STORAGE: อ่านและบันทึกคีย์
-- =========================================================================
local function GetStoredLicenseKey()
    -- Priority 1: อ่านจาก (getgenv()).key หรือ getgenv().Key ตามสไตล์ Maru Hub
    if getgenv().key and getgenv().key ~= "" then
        return tostring(getgenv().key):gsub("%s+", "")
    end
    if getgenv().Key and getgenv().Key ~= "" then
        return tostring(getgenv().Key):gsub("%s+", "")
    end

    -- Priority 2: อ่านจาก Config.lua ที่ผู้ใช้ตั้งไว้ (Config.LicenseKey / Config.Key)
    if getgenv().Config then
        if getgenv().Config.LicenseKey and getgenv().Config.LicenseKey ~= "" then
            return tostring(getgenv().Config.LicenseKey):gsub("%s+", "")
        end
        if getgenv().Config.Key and getgenv().Config.Key ~= "" then
            return tostring(getgenv().Config.Key):gsub("%s+", "")
        end
        if getgenv().Config.key and getgenv().Config.key ~= "" then
            return tostring(getgenv().Config.key):gsub("%s+", "")
        end
    end

    -- Priority 3: อ่านจากไฟล์ sleepshop_key.txt
    if isfile and isfile(KEY_FILENAME) then
        local content = readfile(KEY_FILENAME)
        if content and content ~= "" then
            return tostring(content):gsub("%s+", "")
        end
    end

    return nil
end

local function SaveLicenseKey(key)
    if writefile and key and key ~= "" then
        pcall(function()
            writefile(KEY_FILENAME, tostring(key):gsub("%s+", ""))
        end)
    end
end

-- =========================================================================
-- 5. KEYGEN.SH API VALIDATION
-- =========================================================================
local function ValidateKeyWithKeygen(licenseKey)
    local HttpService = game:GetService("HttpService")
    local fingerprint = GetHardwareFingerprint()

    local endpoint = string.format("https://api.keygen.sh/v1/accounts/%s/licenses/actions/validate-key", ACCOUNT_ID)

    local payload = {
        meta = {
            key = licenseKey,
            scope = {
                product = PRODUCT_ID,
                fingerprint = fingerprint
            }
        }
    }

    local jsonBody = HttpService:JSONEncode(payload)

    local response = HttpRequest({
        Url = endpoint,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/vnd.api+json",
            ["Accept"] = "application/vnd.api+json",
            ["User-Agent"] = "SleepShop-RobloxClient/1.0"
        },
        Body = jsonBody
    })

    if not response or not response.Body then
        return false, "ไม่สามารถเชื่อมต่อไปยังเซิร์ฟเวอร์ตรวจสอบสิทธิ์ Keygen.sh ได้", "NETWORK_ERROR"
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)

    if not success or not data then
        return false, "การตอบกลับจากเซิร์ฟเวอร์ไม่ถูกต้อง", "PARSE_ERROR"
    end

    local meta = data.meta or {}
    local isValid = (meta.valid == true)
    local code = meta.code or "UNKNOWN"
    local detail = meta.detail or ""

    if isValid then
        local licenseData = data.data and data.data.attributes or {}
        local expiry = licenseData.expiry or "ไม่มีวันหมดอายุ (Lifetime)"
        local status = licenseData.status or "ACTIVE"
        return true, {
            status = status,
            expiry = expiry,
            detail = detail,
            key = licenseKey
        }, code
    else
        local reason = "License Key ไม่ถูกต้อง"
        if code == "NOT_FOUND" then
            reason = "ไม่พบคีย์นี้ในระบบ (" .. licenseKey .. ") กรุณาตรวจสอบความถูกต้อง"
        elseif code == "EXPIRED" then
            reason = "License Key นี้หมดอายุการใช้งานแล้ว กรุณาติดต่อร้านค้าเพื่อต่ออายุ"
        elseif code == "SUSPENDED" then
            reason = "License Key นี้ถูกระงับการใช้งานชั่วคราวหรือถาวร"
        elseif code == "NO_MACHINE" or code == "NO_MACHINES" or code == "FINGERPRINT_SCOPE_MISMATCH" then
            reason = "คีย์นี้ถูกใช้งานบนเครื่องอื่นแล้ว หรือจำนวนเครื่องเกินกำหนดที่ได้รับอนุญาต"
        elseif detail and detail ~= "" then
            reason = "ตรวจสอบไม่ผ่าน: " .. detail
        end
        return false, reason, code
    end
end

-- =========================================================================
-- 6. KEY INPUT UI (กรณีที่ยังไม่มีการตั้งคีย์ไว้)
-- =========================================================================
local function PromptKeyUI(callback)
    local lp = game:GetService("Players").LocalPlayer
    local pgui = lp:WaitForChild("PlayerGui")

    local existingGui = pgui:FindFirstChild("SleepShopKeyPrompt")
    if existingGui then existingGui:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "SleepShopKeyPrompt"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = pgui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 220)
    frame.Position = UDim2.new(0.5, -210, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    frame.BorderSizePixel = 0
    frame.Parent = sg

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 75, 120)
    stroke.Thickness = 2

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "🔑 " .. SCRIPT_NAME
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 30)
    desc.Position = UDim2.new(0, 20, 0, 45)
    desc.BackgroundTransparency = 1
    desc.Text = "กรุณากรอก License Key ที่ได้รับจากทางร้าน SleepShop:"
    desc.TextColor3 = Color3.fromRGB(180, 185, 200)
    desc.TextSize = 13
    desc.Font = Enum.Font.Gotham
    desc.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -40, 0, 40)
    box.Position = UDim2.new(0, 20, 0, 85)
    box.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = "กรอก License Key ที่นี่..."
    box.PlaceholderColor3 = Color3.fromRGB(120, 125, 140)
    box.TextSize = 14
    box.Font = Enum.Font.GothamMedium
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -40, 0, 20)
    statusLbl.Position = UDim2.new(0, 20, 0, 130)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = ""
    statusLbl.TextColor3 = Color3.fromRGB(255, 90, 90)
    statusLbl.TextSize = 12
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, 160)
    btn.BackgroundColor3 = Color3.fromRGB(255, 75, 120)
    btn.Text = "ตรวจสอบและเข้าสู่ระบบ 🚀"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        local inputKey = box.Text:gsub("%s+", "")
        if inputKey == "" then
            statusLbl.Text = "⚠️ กรุณากรอกคีย์ก่อนกดยืนยัน"
            return
        end
        statusLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        statusLbl.Text = "⏳ กำลังตรวจสอบสิทธิ์กับ Keygen.sh..."
        btn.Active = false

        task.spawn(function()
            local valid, info, code = ValidateKeyWithKeygen(inputKey)
            if valid then
                statusLbl.TextColor3 = Color3.fromRGB(50, 220, 120)
                statusLbl.Text = "✅ คีย์ถูกต้อง! กำลังเปิดใช้งานสคริปต์..."
                SaveLicenseKey(inputKey)
                task.wait(1)
                sg:Destroy()
                callback(inputKey, info)
            else
                btn.Active = true
                statusLbl.TextColor3 = Color3.fromRGB(255, 90, 90)
                statusLbl.Text = "❌ " .. tostring(info)
            end
        end)
    end)
end

-- =========================================================================
-- 7. LOADER MAIN EXECUTION
-- =========================================================================
local function StartScript(licenseKey, info)
    print("=================================================================")
    print("[KEYGEN] ✅ ยินดีต้อนรับสู่ " .. SCRIPT_NAME)
    print(string.format("[KEYGEN] 🔑 License Key: %s", licenseKey))
    print(string.format("[KEYGEN] 📅 วันหมดอายุ: %s", tostring(info.expiry)))
    print(string.format("[KEYGEN] 🖥️ เครื่อง (HWID): %s", GetHardwareFingerprint()))
    print("=================================================================")

    -- เริ่มโหลดไฟล์สคริปต์หลัก auto_farm_gems.lua อย่างปลอดภัย
    if SCRIPT_RAW_URL and SCRIPT_RAW_URL ~= "" then
        local success, src = pcall(game.HttpGet, game, SCRIPT_RAW_URL)
        if success and src and src ~= "" then
            loadstring(src)()
            return
        end
    end

    if isfile and isfile("auto_farm_gems.lua") then
        loadfile("auto_farm_gems.lua")()
    elseif isfile and isfile("Config.lua") then
        loadfile("Config.lua")()
    else
        loadstring(readfile("auto_farm_gems.lua"))()
    end
end

-- รันกระบวนการตรวจสอบ
task.spawn(function()
    AntiTamperCheck()

    local key = GetStoredLicenseKey()
    if key and key ~= "" then
        print("[KEYGEN] กำลังตรวจสอบ License Key อัตโนมัติ: " .. key .. "...")
        local valid, info, code = ValidateKeyWithKeygen(key)
        if valid then
            StartScript(key, info)
            return
        else
            warn("[KEYGEN] คีย์ที่บันทึกไว้ไม่ผ่าน: " .. tostring(info))
        end
    end

    -- หากยังไม่มีคีย์ หรือคีย์เก่าหมดอายุ ให้แสดงหน้าต่างกรอกคีย์
    PromptKeyUI(function(validKey, info)
        StartScript(validKey, info)
    end)
end)
