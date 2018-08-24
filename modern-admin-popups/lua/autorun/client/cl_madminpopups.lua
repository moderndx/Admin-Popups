include("autorun/modern_admin_cfg.lua")

local popups = popups || {}

local function create_notification(player, request, claimed)
  local w, h = 275, 125

  local m_bhandle = false

  if (claimed && claimed:IsValid()) then
    m_bhandle = true
  end

  local notification_frame = vgui.Create("DFrame")
  notification_frame.plr = player
  notification_frame.handle = m_bhandle
  notification_frame:SetSize(w,h)
  notification_frame:SetPos(25, 25)
  notification_frame:ShowCloseButton(false)
  function notification_frame:Paint(w, h)
    draw.RoundedBox( 4, 0, 0, w, h, admin_popups.BackgroundColor )
    draw.RoundedBox( 0, 0, 0, w, 20, admin_popups.AccentColor )
  end
  notification_frame.lblTitle:SetColor(Color(0, 0, 0))
  notification_frame.lblTitle:SetContentAlignment(7)

  if claimed && claimed:IsValid() then
    notification_frame:SetTitle(player:Nick().." - Claimed By "..claimed:Nick())
  else
    notification_frame:SetTitle(player:Nick())
  end

  local close_button = vgui.Create("DButton", notification_frame)
  close_button:SetText("×")
  close_button:SetColor(Color(0, 0, 0))
  close_button:SetPos(w-20, 2)
  close_button:SetSize(15, 15)
  function close_button:Paint(w,h) end
  close_button.DoClick = function()
    notification_frame:Close()
    timer.Remove("m_popup_id"..player:SteamID64())
  end

  local request_txt = vgui.Create("RichText", notification_frame)
  request_txt:SetPos(15, 30)
  request_txt:SetSize(w - 100, h - 35)
  request_txt:SetContentAlignment(7)
  request_txt:InsertColorChange( 255, 255, 255, 255 )
  request_txt:SetVerticalScrollbarEnabled(false)
  function request_txt:PerformLayout()
    request_txt:SetFontInternal( "DermaDefault" )
  end
  request_txt:AppendText(request.."\n")

  local go_to_button = vgui.Create("DButton", notification_frame)
  go_to_button:SetPos(202, 21 * 1)
  go_to_button:SetSize(70, 18)
  go_to_button:SetText("Goto")
  go_to_button:SetColor(Color(0, 0, 0))
  go_to_button:SetContentAlignment(5)
  go_to_button:SetTextColor( Color( 0, 0, 0 ) )
  go_to_button.Paint = function( self, w, h ) draw.RoundedBox( 0, 0, 0, w, h, admin_popups.AccentColor ) end
  go_to_button.DoClick = function()
    LocalPlayer():ConCommand("ulx goto $"..notification_frame.plr:SteamID())
  end

  local return_button = vgui.Create("DButton", notification_frame)
  return_button:SetPos(202, 21 * 2)
  return_button:SetSize(70, 18)
  return_button:SetText("Return")
  return_button:SetColor(Color(0, 0, 0))
  return_button:SetContentAlignment(5)
  return_button:SetTextColor( Color( 0, 0, 0 ) )
  return_button.Paint = function( self, w, h ) draw.RoundedBox( 0, 0, 0, w, h, admin_popups.AccentColor ) end
  return_button.DoClick = function()
    LocalPlayer():ConCommand("ulx return ^")
  end

  local freeze_button = vgui.Create("DButton", notification_frame)
  freeze_button:SetPos(202, 21 * 3)
  freeze_button:SetSize(70, 18)
  freeze_button:SetText("Freeze")
  freeze_button:SetColor(Color(0, 0, 0))
  freeze_button:SetContentAlignment(5)
  freeze_button:SetTextColor( Color( 0, 0, 0 ) )
  freeze_button.Paint = function( self, w, h ) draw.RoundedBox( 0, 0, 0, w, h, admin_popups.AccentColor ) end
  freeze_button.DoClick = function()
    LocalPlayer():ConCommand("ulx freeze $"..notification_frame.plr:SteamID())
  end

  local strip_button = vgui.Create("DButton", notification_frame)
  strip_button:SetPos(202, 21 * 4)
  strip_button:SetSize(70, 18)
  strip_button:SetText("Strip")
  strip_button:SetColor(Color(0, 0, 0))
  strip_button:SetContentAlignment(5)
  strip_button:SetTextColor( Color( 0, 0, 0 ) )
  strip_button.Paint = function( self, w, h ) draw.RoundedBox( 0, 0, 0, w, h, admin_popups.AccentColor ) end
  strip_button.DoClick = function()
    LocalPlayer():ConCommand("ulx strip $"..notification_frame.plr:SteamID())
  end

  local handle_case_button = vgui.Create("DButton", notification_frame)
  handle_case_button:SetPos(202, 21 * 5)
  handle_case_button:SetSize(70, 18)
  handle_case_button:SetText(notification_frame.handle and "Close" or "Claim")
  handle_case_button:SetColor(Color(0,0,0))
  handle_case_button:SetContentAlignment(5)
  handle_case_button:SetTextColor( Color( 0, 0, 0 ) )
  handle_case_button.Paint = function( self, w, h ) draw.RoundedBox( 0, 0, 0, w, h, admin_popups.AccentColor ) end
  handle_case_button.DoClick = function()
    net.Start(notification_frame.handle and "modern_close_popup" or "modern_claim_popup")
    net.WriteEntity(player)
    net.SendToServer()
  end

  notification_frame:SetPos( -w - 30, 25 + (130 * #popups) )
  notification_frame:MoveTo( 25, 25 + (130 * #popups), 0.2, 0, 1)

  function notification_frame:OnRemove()
    table.RemoveByValue(popups, notification_frame)
    for k,v in pairs(popups) do
      v:MoveTo( 25, 25 + ( 130 * ( k - 1 ) ), 0.1, 0, 1 )
    end
  end

  timer.Create( "m_popup_id"..player:SteamID64() , 120, 1, function()
    if (notification_frame && notification_frame:IsValid()) then notification_frame:Remove() end
    net.Start("modern_close_popup")
    net.WriteEntity(player)
    net.SendToServer()
  end)
  table.insert(popups, notification_frame)
end

local function update_old(user, message)
  for k,v in pairs(popups) do
    if (v.plr == user) then
      v:GetChildren()[6]:AppendText(message.."\n")
    end
  end
end

local function change_claim(user, admin)
  for k,v in pairs(popups) do
    if (v.plr == user) then
      v:SetTitle(user:Nick().." - Claimed By "..admin:Nick())
      v.handle = true
      local btn = v:GetChildren()[11]
      btn:SetText("Close")
    end
  end
end

local function close_case(user)
  for k,v in pairs(popups) do
    if (v.plr == user) then
      v:Remove()
      timer.Remove("m_popup_id"..user:SteamID64())
    end
  end
end

local function create_case(user, request, claimed)
  create_notification(user, request, claimed)
end

net.Receive("modern_send_popup", function(len, ply)
  local tbl = net.ReadTable()
  local player = tbl["ply"]
  local request = tbl["msg"]
  local claimed = tbl["claim"]
  local open = tbl["open"]

  if (player == LocalPlayer()) then return end

  if (request == "1") then --claimed
    change_claim(player, claimed)
    return
  end

  if (request == "2") then --closed
    close_case(player)
    return
  end

  if (!open) then create_case(player, request, claimed)
  else update_old(player, request)
  end
end)
