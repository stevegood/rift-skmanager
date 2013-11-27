--
-- User: Ardoth
-- Date: 11/27/13
-- Time: 9:20 AM
--

raidService = {}

-- Sample string
-- Ardoth's Saturday TDQ:=Cleric:@Terela:!level::60!!listPosition::0!!substitute::false,Arty:!level::60!!listPosition::1!!substitute::false,Adalei:!level::60!!listPosition::3!!substitute::false:#Mage:@Knopix:!level::60!!listPosition::0!!substitute::false:#Rogue:@Ardoth:!level::60!!listPosition::0!!substitute::false,Dmoney:!level::60!!listPosition::1!!substitute::false,Zurra:!level::60!!listPosition::2!!substitute::false,Mazu:!level::60!!listPosition::6!!substitute::false:#Warrior:@Demogoth:!level::60!!listPosition::0!!substitute::false,Ashleechan:!level::60!!listPosition::1!!substitute::false

function raidService.parseRaidString(raidString)
    local characterData = {callings = {}}

    local raidStringParts = string.split(raidString, ":=")
    local raidStringData = raidStringParts[2]
    local raidName = raidStringParts[1]
    characterData.name = raidName

    for i, d in pairs(string.split(raidStringData, ":#")) do
        local callingParts = string.split(d, ":@")
        local callingName = callingParts[1]
        local callingTable = {name = callingName, members = {}}
        for n, m in pairs(string.split(callingParts[2], ",")) do
            local memberParts = string.split(m, ":!")
            local memberName = memberParts[1]
            local memberTable = {name = memberName}
            for nn, p in pairs(string.split(memberParts[2], "!!")) do
                local propParts = string.split(p, "::")
                memberTable[propParts[1]] = propParts[2]
            end
            table.insert(callingTable.members, memberTable)
        end
        table.sort(callingTable.members,function(x,y)
            return x.listPosition < y.listPosition
        end)
        table.insert(characterData.callings, callingTable)
    end

    -- sort the callings table
    table.sort(characterData.callings, function(x,y)
        return x.name < y.name
    end)

    return characterData
end

function raidService.buildRaidString(raid)
    local callings = {}
    for i, v in pairs(raid.callings) do
        local members = {}
        for ix, va in pairs(v.members) do
            local props = {}
            for key, val in pairs(va) do
                if (key ~= "name") then
                    table.insert(props, key.."::"..val)
                end
            end
            table.insert(members,va.name..":!"..table.concat(props, '!!'))
        end
        table.insert(callings,v.name..":@"..table.concat(members, ','))
    end
    return raid.name..":="..table.concat(callings, ':#')
end
