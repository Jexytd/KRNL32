const { Client, MessageEmbed, Message } = require('discord.js');
const { Token,Prefix } = require('./config.json');
const fs = require('fs');
const { stringify } = require('querystring');
const client = new Client();

client.on('ready', () => {
    console.log('Log on as ', client.user.tag);
});

client.on('message', (message) => {
    if (!message.content.startsWith(Prefix) || message.author.bot) return;

    const args = message.content.slice(Prefix.length).trim().split(/ +/)
    const command = args.shift().toLowerCase();
    if (!command) return;

    if (command == "getkey") {
        try {  
            
            /*
                ROBLOX:

                1. Exeucted with variable 'key' -> 2

                2. if key == data[key] and data[robloxid] ~= "" then execute(script); end. ELSE jmp to -> 3

                3. if key == data[key] and data[robloxid] == "" then
                    local url = "https://127.0.0.0/sc/test.php";
                    local param = "?s=";

                    locla data = (function()
                        local json = "https://navicat.glitch.me/db.json"
                        local x = HttpService:JSONDecode(game:HttpGet(json));
                        local response; // nil
                        // x -> table: { {"DiscordID", "key_abcde", ""} }
                        for i in pairs(x) do
                            if x[i][2] == Key then
                                if x[i][3] == "" then
                                    x[i][3] = tostring(client.UserId);
                                    game:HttpGet(url .. param .. HttpService:JSONEncode(x)) // Send -> php: rewrite db.json with sended code -> return data rewrite?
                                    response = request({url=json, Method="GET", Headers={ ["Content-Type"] = "application/json" }})
                                elseif x[i][3] == tostring(client.UserId) then
                                    response = request({url=json, Method="GET", Headers={ ["Content-Type"] = "application/json" }})
                                end
                            end
                        end

                        return response
                    end)()
                    
                    if data.Success then
                        // script
                    else
                        return print("Okeh")
                    end

                    // what i gonna send to the url ? table but encoded to json
                    
                    // what table/json? its json from discord bot which is data of key 
                    


                end
            */

            const data = require("./db.json");
            var Key = "key_";
            var id = message.author.id;

            function random(length) {
                var result           = '';
                var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
                var charactersLength = characters.length;
                for ( var i = 0; i < length; i++ ) {
                  result += characters.charAt(Math.floor(Math.random() * charactersLength));
               }
               return result;
            }
            Key += random(6);
            var currentData;

            for (var i = 0; i < (data.length + 1); i++) {
                if (i < data.length && !data[i].includes(id) && data[i].includes(Key)) {
                    Key = "key_" + random(6)
                }

                if (i < data.length && data[i].includes(id)) {
                    Key = data[i][1];
                    currentData = require('./db.json');
                    break;
                }

                if (i < data.length && !data[i].includes(id)) {
                } else {
                    data.push([id, Key, ""])
                    fs.writeFile(
                        "./db.json",
                        JSON.stringify(data, null, 1),
                        function (err) {
                            if (err) {
                                console.error('Crap happens');
                            }
                        }
                    )
                    currentData = require('./db.json');
                    break
                }
            }

            if (currentData) {
                var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
                var xhr = new XMLHttpRequest();
                var url = 'https://ikan101.000webhostapp.com/check.php'
                var params = '?s=' + JSON.stringify(currentData)

                xhr.open("POST", url + params, true);
                xhr.send(params);
            }

            const Embed = new MessageEmbed()
            .setColor('0x8d6c9f')
            .setTitle(command.charAt(0).toUpperCase() + command.slice(1))
            .setAuthor(message.author.tag, message.author.avatarURL({ format: 'png', dynamic: true }))
            .setDescription('This is your key for using the script\nAfter generate the key, the key will doesn\'t change.\nRemember the key its limited to 1 roblox account\n```'+ Key + '```')
            .setTimestamp()
            .setFooter(client.user.tag, client.user.avatarURL({ format: 'png', dynamic: true }))

            message.channel.send(Embed)
        } catch (err) {
            console.error(err)
        }
    }
});

client.login(Token);