local allowed = false
local httpResponse = http.get("https://pastebin.com/raw/mdKHXLzK").readAll()
local computerId = os.computerId()
for line in httpResponse:gmatch("([^\n]*)\n?") do
    if(line == "" .. computerId) then
        allowed = true
        break
    end
end
if(not allowed) then
    print("Please do not use this program unless you have a license to do so.")
    print("If you would like a license, ask Jmeow for a price.")
    os.exit(1)
end
term.clear()
term.setCursorPos(1, 1)
print("Enjoy!")
items = {}
itemSlots = {}
itemNames = {}
chests = {}
for _, chest in pairs({peripheral.find("minecraft:chest")}) do
  	table.insert(chests, chest)
end
function refresh()
    items = {}
    itemNames = {}
    local chestId = 1
    for _, chest in pairs(chests) do
        itemSlots[chestId] = {}
        local slots = {}
        local chestSize = chest.size()
        for slot = 1, chestSize, 1 do
            slots[slot] = chest.getItemDetail(slot)
            if(slots[slot]) then
                itemSlots[chestId][slots[slot].name] = itemSlots[slots[slot].name] or {}
                table.insert(itemSlots[chestId][slots[slot].name], slot)
            end
        end
        for unusedthing, item in pairs(slots) do
            if(item) then
                items[item.displayName] = (items[item.displayName] or 0) + item.count
                itemNames[item.displayName] = item.name
            end
        end
        chestId = chestId + 1
    end
    --[[
    local chest = peripheral.find("minecraft:chest")
    items = {}
    itemNames = {}
    local slots = {}
    local chestSize = chest.size()
    for slot = 1, chestSize, 1 do
        slots[slot] = chest.getItemDetail(slot)
        if(slots[slot]) then
            itemSlots[slots[slot].name] = itemSlots[slots[slot].name] or {}
            table.insert(itemSlots[slots[slot].name], slot)
        end
    end
    for unusedthing, item in pairs(slots) do
        if(item) then
            items[item.displayName] = (items[item.displayName] or 0) + item.count
            itemNames[item.displayName] = item.name
        end
    end
    --]]
end
function render()
    local monitor = peripheral.find("monitor")
    monitor.setTextScale(0.5)
    monitor.setCursorBlink(false)
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    local width, height = monitor.getSize()
    local i = 0
    for name, count in pairs(items) do
        monitor.setCursorPos((i * 25) % (math.floor(width / 25) * 25) + 1, math.floor(i / math.floor(width / 25)) + 1)
        if(i % 2 == 0)
        then
            monitor.setBackgroundColor(colors.gray)
        else
            monitor.setBackgroundColor(colors.lightGray)
        end
        monitor.write(("%-19s x%-4d"):format(name:sub(1, 19), count))
        i = i + 1
    end
    monitor.setBackgroundColor(colors.black)
    monitor.setCursorPos(width - 6, height)
    monitor.write("Refresh")
end
local monitor = peripheral.find("monitor")
monitor.setTextScale(0.5)
monitor.setCursorBlink(false)
monitor.setBackgroundColor(colors.black)
monitor.clear()
monitor.setCursorPos(1, 1)
monitor.write("Thanks for using Jmeow's Inventory System!")
monitor.setCursorPos(1, 2)
monitor.write("The data is now loading. The more chests you have, the slower it is,")
monitor.setCursorPos(1, 3)
monitor.write("because of ComputerCraft's unique API. This issue is not fixable by Jmeow,")
monitor.setCursorPos(1, 4)
monitor.write("sorry about any inconvenience!")
monitor.setCursorPos(1, 5)
monitor.write("Hopefully by now it'll have finished loading soon, but if it hasn't, don't worry!")
monitor.setCursorPos(1, 6)
monitor.write("Just keep reading this text that seems to go on forever! If you're still")
monitor.setCursorPos(1, 7)
monitor.write("reading this after a minute or two, maybe open up your computer")
monitor.setCursorPos(1, 8)
monitor.write("to see if any errors happened. If they haven't, just keep waiting!")
monitor.setCursorPos(1, 9)
monitor.write("It'll work eventually. Enjoy!")
refresh()
render()
local alarm_id = os.setAlarm(os.time() + 0.02)
while true do
  	local eventData = {os.pullEventRaw()}
    local event = eventData[1]
    if event == "monitor_touch" then
        local monitor = peripheral.find("monitor")
        local width, height = monitor.getSize()
        local x, y = eventData[3], eventData[4]
        if(y == height and x > width - 6) then
            monitor.setBackgroundColor(colors.black)
            monitor.setCursorPos(width - 12, height)
            monitor.write("Refreshing...")
            refresh()
            render()
        end
        local i = 0
        for name, count in pairs(items) do
            if(x > (i * 25) % (math.floor(width / 25) * 25) and x < (i * 25) % (math.floor(width / 25) * 25) + 26 and y == math.floor(i / math.floor(width / 25)) + 1) then
                local chestId = 1
                for _, chest in pairs(chests) do
                    print(textutils.serializeJSON(itemSlots[chestId]))
                    print(itemNames[name])
                    local fixedSlotList = {}
                    for key, value in pairs(itemSlots[chestId][itemNames[name]] or {}) do
                        fixedSlotList[key] = value
                        print(textutils.serialize(key), "=", textutils.serialize(value))
                    end
                    --print(textutils.serializeJSON({#itemSlots[chestId][itemNames[name]]}))
                    if(fixedSlotList[1]) then
                        print(textutils.serializeJSON(chest.getItemDetail(fixedSlotList[1])))
                        chest.pushItems("minecraft:dropper_0", fixedSlotList[1], 1)
                        print("asdf")
                        peripheral.find("computer").turnOn()
                        items[name] = items[name] - 1
                        if(chest.getItemDetail(fixedSlotList[1]) == nil) then
                            table.remove(itemSlots[chestId][itemNames[name]], 1)
                            local foundSlots = 0
                            for key, value in pairs(itemSlots[chestId][itemNames[name]] or {}) do
                                foundSlots = foundSlots + 1
                            end
                            if(foundSlots == 0) then
                                itemSlots[chestId][itemNames[name]] = nil
                            end
                        end
                        break
                    end
                    chestId = chestId + 1
                end
                if(items[name] < 1) then
                    items[name] = nil
                end
                render()
            end
            i = i + 1
        end
    elseif event == "alarm" then
        if(eventData[2] == alarmId) then
            
            alarm_id = os.setAlarm(os.time() + 0.02)
        end
    elseif event == "terminate" then
        local monitor = peripheral.find("monitor")
        monitor.setTextScale(0.5)
        monitor.setCursorBlink(false)
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
        break
    end
end
