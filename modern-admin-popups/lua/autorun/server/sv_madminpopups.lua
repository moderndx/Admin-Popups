// == networking
util.AddNetworkString("modern_send_popup")
util.AddNetworkString("modern_claim_popup")
util.AddNetworkString("modern_close_popup")

// == utils
local function setup_spawn(player)
  player.CaseClaimed = nil
  player.CaseOpen = false
end

local function player_access(ply)
  return ply:query("ulx seeasay")
end

local function send_request_update(player_req, request)
  for k,v in pairs(player.GetAll()) do
    if (player_access(v)) then
      local notify_table = {
        ["ply"]     = player_req,
        ["msg"]     = request,
        ["claim"]   = player_req.CaseClaimed,
        ["open"]   = player_req.CaseOpen
      }
      net.Start("modern_send_popup")
      net.WriteTable(notify_table)
      net.Send(v)
    end
  end
end

local function update_notification(player, request)
  send_request_update(player, request)
end

local function claim_case(player, admin)
  player.CaseClaimed = admin
  send_request_update(player, "1") --claimed
end

local function open_case(player, request)
  send_request_update(player, request)
  player.CaseOpen = true
end

local function close_case(player)
  player.CaseOpen = false
  player.CaseClaimed = nil
  send_request_update(player, "2") --closed
end

local function check_cmd(ply, cmd, args)
  if string.find(cmd, "ulx asay") && admin_popups.DisableAdminsPopup && ply:query("ulx asay") && player_access(ply) then return end
  if string.find(cmd, "ulx asay") && ply:query("ulx asay") && table.Count(args) > 0 then
    if (!ply.CaseOpen) then open_case(ply, table.concat(args," ")) return end
    if (ply.CaseOpen) then update_notification(ply, table.concat(args," ")) return end
  end
end

local function player_disc(ply)
  close_case(ply)
end

net.Receive("modern_claim_popup", function(len, ply)
  local user = net.ReadEntity()
  if player_access(ply) && !user.CaseClaimed then
    claim_case(user, ply)
  end
end)

net.Receive("modern_close_popup", function(len, ply)
  local user = net.ReadEntity()
  if player_access(ply) && user.CaseClaimed then
    close_case(user)
  end
end)

// == hooks
hook.Add( "ULibCommandCalled", "command_check_mpopup", check_cmd )
hook.Add( "PlayerInitialSpawn", "spawn_setup_mpopup", setup_spawn )
hook.Add( "PlayerDisconnected", "disc_close_mpopup", player_disc )
