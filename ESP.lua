local ESP = {
    Aktif = false,
    Kotak = false,
    Nama = false,
    Garis = false,
    HealthBox = false,
    Jarak = false,
    
    JarakMaksimal = math.huge,
    Tim = true,
    WarnaTim = true,
    Objek = setmetatable({}, {__mode = 'kv'}),

    Warna = Color3.fromRGB(255,255,255),
    Ketebalan = 2
};

local pemain = game:GetService("Players"); --: mendeklarasikan pemain
local client,cam = pemain.LocalPlayer, workspace.CurrentCamera; --: mendeklarasikan klien dan kamera klien
local Vec3 = Vector3.new; --: mendeklarasikan vektor baru
local WTViewPoint = cam.WorldToViewportPoint; --: mendeklarasikan objek ke sudut pandang klien

function Draw(objek, opsi) --: mendeklarasikan 'Gambar' dengan parameter: objek (object/instance), opsi (table/data)
    local Drawing = Drawing.new(objek) --: membuat Gambaran dengan nilai objek

    for i,v in pairs(opsi or {}) do --: mengambil data opsi jika ada deklarasi dengan for looping iteration 
        Drawing[i] = v; --: memasang properti objek dengan nilai opsi
    end
    return Drawing --: megembalikan objek
end;

local data_Kotak = {};
data_Kotak.__index = data_Kotak;

function data_Kotak:Remove()
    ESP.Objek[self.Objek] = nil
    for i,v in pairs(self.Komponen) do
        v.Visible = false
        v:Remove()
        self.Komponen[i] = nil
    end
end

function data_Kotak:Perbaru()
    if not self.MainPart then
        return self:Remove();
    end

    local warna;
    if ESP.Highlighted == self.Objek then
        warna = ESP.HighlightColor
    else
        warna = self.Pemain.Team.TeamColor.Color or self.Color or ESP.Color
    end

    local allow = true
    if self.Pemain and not ESP.Tim and self.Pemain.Team == client.Team then
        allow = false
    end
    if self.IsAktif and (type(self.IsAktif) == "string" and not ESP[self.IsAktif] or type(self.IsAktif) == "function" and not self:IsAktif()) then
        allow = false
    end
    if not workspace:IsAncestorOf(self.MainPart) then
        allow = false
    end

    if not allow then
        for i,v in pairs(self.Komponen) do
            v.Visible = false
        end
        return
    end

    if ESP.Highlighted == self.Objek then
        warna = ESP.HighlightColor
    end

    --: WTViewpoint
    local cframe = self.MainPart.CFrame
    local size = self.Size

    local penempatan = {
        AtasKiri = cframe * CFrame.new(size.X / 2, size.Y / 2, 0),
        AtasKanan = cframe * CFrame.new(-size.X / 2, size.Y / 2, 0),
        BawahKiri = cframe * CFrame.new(size.X / 2, -size.Y / 2, 0), --: Minus Y karena ingin menempatkan garis di bawah
        BawahKanan = cframe * CFrame.new(-size.X / 2, -size.Y / 2, 0), --: Minus Y karena ingin menempatkan garis di bawah
        PosNama = cframe * CFrame.new(0, size.Y / 2, 0),
        Part = cframe * CFrame.new(0, -1.5, 0)
    }

    if ESP.Kotak then
        local A1,A2,B1,B2 = penempatan["AtasKiri"],penempatan["AtasKanan"],penempatan["BawahKiri"],penempatan["BawahKanan"]
        local AtasKiri, Vis1 = WTViewPoint(cam, A1.p)
        local AtasKanan, Vis2 = WTViewPoint(cam, A2.p)
        local BawahKiri, Vis3 = WTViewPoint(cam, B1.p)
        local BawahKanan, Vis4 = WTViewPoint(cam, B2.p)
        
        if self.Komponen.Kotak then
            if Vis1 or Vis2 or Vis3 or Vis4 then
                self.Komponen.Kotak.Visible = true
                self.Komponen.Kotak.PointA = Vector2.new(TopRight.X, TopRight.Y)
                self.Komponen.Kotak.PointB = Vector2.new(TopLeft.X, TopLeft.Y)
                self.Komponen.Kotak.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y)
                self.Komponen.Kotak.PointD = Vector2.new(BottomRight.X, BottomRight.Y)
                self.Komponen.Kotak.Color = warna
            else
                self.Komponen.Kotak.Visible = false
            end
        end
    else
        self.Komponen.Kotak.Visible = false
    end

    if ESP.Nama then
        local Pos, Vis = WTViewPoint(cam, penempatan.PosNama.p)

        if self.Komponen.Nama then
            if Vis then
                self.Komponen.Nama.Visible = true
                self.Komponen.Nama.Position = Vector2.new(Pos.X, Pos.Y)
                self.Komponen.Nama.Text = self.Nama
                self.Komponen.Nama.Color = warna
                
                self.Komponen.Jarak.Visible = true
                self.Komponen.Jarak.Position = Vector2.new(Pos.X, Pos.Y + 14)
                self.Komponen.Jarak.Text = math.floor((cam.CFrame.p - cframe.p).magnitude) .."m away"
                self.Komponen.Jarak.Color = warna
            else
                self.Komponen.Nama.Visible = false
                self.Komponen.Jarak.Visible = false
            end
        else
            self.Komponen.Nama.Visible = false
            self.Komponen.Jarak.Visible = false
        end
    end

    if ESP.Garis then
        local pos, vis = WTViewPoint(cam, penempatan.Part.p)

        if self.Komponen.Garis then
            if Vis then
                self.Komponen.Garis.Visible = true
                self.Komponen.Garis.From = Vector2.new(pos.X, pos.Y)
                self.Komponen.Garis.To = Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/1)
                self.Komponen.Garis.Color = warna
            else
                self.Komponen.Garis.Visible = false
            end
        end
    else
        self.Komponen.Garis.Visible = false
    end
end

do
    function ESP:Toggle(x)
        self.Aktif = x;
    end;

    function ESP:Create(objek, opsi)
        if not objek.Parent then
            return warn(objek, 'Tidak mempunyai parent. Gagal untuk membuat esp!')
        end;

        local Kotak = setmetatable({
            Nama = opsi.Nama or objek.Nama,
            Warna = opsi.Warna or self.Warna,
            Size = opsi.Size,

            Objek = objek, 
            Pemain = opsi.Pemain or pemain:GetPlayerFromCharacter(objek),
            MainPart = opsi.MainPart or objek.ClassNama == "Model" and (objek.PrimaryPart or objek:FindFirstChild("HumanoidRootPart") or objek:FindFirstChildWhichIsA("BasePart")) or objek:IsA("BasePart") and objek,
            Komponen = {},
            IsAktif = opsi.IsAktif
        }, data_Kotak);

        if self.Objek[objek] then
            self.Objek[objek]:Remove()
        end

        Kotak.Komponen["Box"] = Draw("Quad", {
            Thickness = self.Ketebalan,
            Color = color,
            Transparency = 1,
            Filled = false,
            Visible = self.Aktif and self.Kotak
        });

        Kotak.Komponen["Nama"] = Draw("Text", {
            Color = Kotak.Warna,
            Center = true,
            Outline = true,
            Size = 19,
            Visible = self.Aktif and self.Nama
        });

        Kotak.Komponen["Jarak"] = Draw("Text", {
            Color = Kotak.Warna,
            Center = true,
            Outline = true,
            Size = 19,
            Visible = self.Aktif and self.Jarak
        });

        Kotak.Komponen["Garis"] = Draw("Line", {
            Thickness = self.Ketebalan,
            Color = Kotak.Warna,
            Transparency = 1,
            Visible = self.Aktif and self.Garis
        });
        self.Objek = Kotak;

        objek.AncestryChanged:Connect(function(_, parent)
            if parent == nil and ESP.AutoRemove ~= false then
                Kotak:Remove()
            end
        end)
        objek:GetPropertyChangedSignal("Parent"):Connect(function()
            if objek.Parent == nil and ESP.AutoRemove ~= false then
                Kotak:Remove()
            end
        end)
    
        local hum = objek:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function()
                if ESP.AutoRemove ~= false then
                    Kotak:Remove()
                end
            end)
        end

        return Kotak
    end;
end;

--: Skeet!
local function CharAdded(char)
    local p = pemain:GetPlayerFromCharacter(char)
    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                ESP:Create(char, {
                    Nama = p.Name,
                    Pemain = p,
                    MainPart = c
                })
            end
        end)
    else
        ESP:Create(char, {
            Nama = p.Name,
            Pemain = p,
            MainPart = char.HumanoidRootPart
        })
    end
end
local function PlayerAdded(p)
    p.CharacterAdded:Connect(CharAdded)
    if p.Character then
        coroutine.wrap(CharAdded)(p.Character)
    end
end
pemain.PlayerAdded:Connect(PlayerAdded)
for i,v in pairs(pemain:GetPlayers()) do
    if v ~= client then
        PlayerAdded(v)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    cam = workspace.CurrentCamera
    for i,v in (ESP.Aktif and pairs or ipairs)(ESP.Objek) do
        if v.Perbaru then
            local s,e = pcall(v.Perbaru, v)
            if not s then warn("[EU]", e, v.Objek:GetFullName()) end
        end
    end
end)

return ESP;