local offset_ang = Angle( 15, 0, -15 )
local offset_pos = Vector( -4.8, -1.5, 1 )
local model_path = "models/player/items/soldier/hat_third_nr.mdl"

if not file.Exists( model_path, "GAME" ) then
    model_path = "models/player/items/humans/top_hat.mdl"
    offset_ang = Angle( -15, 0, 10 )
    offset_pos = Vector( -1.1, -3, -1 )
end

local mdl = Model( model_path )

local PLAYER = FindMetaTable( "Player" )
function PLAYER:IsErickMaksimets()
    return self:SteamID64() == "76561198152226525"
end

function PLAYER:IsErickMaksimetsModel()
    return self:GetModel() == "models/player/group03/male_07.mdl"
end

local IsValid = IsValid
local ClientsideModel = ClientsideModel

local function HatThink( ply, callback )
    if IsValid( ply.Hat ) then
        callback( ply.Hat )
        return
    end

    ply.Hat = ClientsideModel( mdl )
    ply.Hat:SetNoDraw( true )
end

local attachment_name = "eyes"
local vector_zero, angle_zero = Vector(), Angle()
local function PosHat( hat, ply )
    local attachment_id = ply:LookupAttachment( attachment_name )
    if (attachment_id > 0) then
        local attachment = ply:GetAttachment( attachment_id )

        local ang = attachment.Ang
        hat:SetModelScale( 1.025, 0 )
        ang:RotateAroundAxis( ang:Right(), 20 )

        return (attachment.Pos + (ang:Forward() * offset_pos[1]) + (ang:Up() * offset_pos[2]) + (ang:Right() * offset_pos[3])), ang
    end

    return vector_zero, angle_zero
end

hook.Add("CreateClientsideRagdoll", "Maksimets_Hat", function( ply, ragdoll )
    if ply:IsPlayer() and ply:IsErickMaksimets() and ply:IsErickMaksimetsModel() then
        function ragdoll:RenderOverride( flags )
            self:DrawModel( flags )
            HatThink(ragdoll, function( hat )
                local pos, ang = PosHat( hat, ragdoll)
                hat:SetRenderOrigin( pos )
                hat:SetRenderAngles( ang + offset_ang )
                hat:DrawModel( flags )
            end)
        end
    end
end)

hook.Add("PostPlayerDraw", "Maksimets_Hat", function( ply, flags )
    if ply:IsBot() then return end
    if ply:IsErickMaksimets() and ply:IsErickMaksimetsModel() and ply:Alive() then
        HatThink(ply, function( hat )
            local pos, ang = PosHat( hat, ply )
            hat:SetRenderOrigin( pos )
            hat:SetRenderAngles( ang + offset_ang )
            hat:DrawModel( flags )
        end)
    elseif IsValid( ply.Hat ) then
        ply.Hat:Remove()
    end
end)