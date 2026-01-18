local url = ""
local ws = nil
local converter = require("/converter")
os.sleep(1)

function connect()
    print("Connecting...")
    local ok, err = pcall(function()
        ws = http.websocket(url)
    end)
    if ok and ws then
        print("Connected!")
        ws.send(textutils.serializeJSON({protocol = "pc", type = "handshake", pc_id = os.getComputerID(), label = "test", converter = "test", timestamp = 12345}))
        return true
    else
        print("Connection failed.")
        return false
    end
end

while not connect() do
    print("Reconnect in 5s...")
    sleep(5)
end

while true do
    local ms = os.epoch("utc")
    local unix_timestamp = math.floor(ms / 1000)
    local ws_text = ws.receive(1)
    if ws_text then
        converter.command(ws_text)
    end

    local ok, err = pcall(function()
        ws.send(textutils.serializeJSON({protocol = "pc", type = "command", pc_id = os.getComputerID(), label = "test", converter = "test", timestamp = unix_timestamp, data = converter.send()}))
    end)
    if not ok then
        print("Reconnect in 5s...")
        sleep(5)
        while not connect() do
            print("Reconnect in 5s...")
            sleep(5)
        end
    end
end

