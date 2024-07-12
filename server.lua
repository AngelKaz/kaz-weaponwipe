local Weapons = {
    "WEAPON_PISTOL",
    "WEAPON_KNIFE"
}
-- Items der skal fjernes (Spawn kode) :)

RegisterCommand("weaponwipe", function(source)
    if source == 0 then
        WeaponWipe()
    end
end)

function WeaponWipe()
    local result = MySQL.Sync.fetchAll("SELECT * FROM vrp_users")
    
    for k,v in pairs(result) do
        MySQL.Async.execute('SELECT * FROM vrp_user_data WHERE user_id = @id', { id = v.id }, function(data)
            if #data > 0 then
                local userdata = json.decode(data[1].dvalue)
    
                userdata.weapons = {}
    
                for k,v in pairs(userdata.inventory) do
                    for _,w in pairs(Weapons) do
                        if k == w then
                            userdata.inventory[k] = nil
                        end
                    end
                end
    
                MySQL.Async.execute("UPDATE vrp_user_data SET dvalue = @data WHERE user_id = @id", { data = json.encode(userdata), id = v.id })
            end
    
            Wait(10)
            print('Wiped weapons for user: ' .. v.id)
        end)
    end
end