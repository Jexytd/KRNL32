const XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;

module.exports = {
	name: 'getkey',
	description: 'Get a key',
    guilds: true,
	execute(message, args, client) {
        try {  
            function random(length) {
                var result           = '';
                var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
                var charactersLength = characters.length;
                for ( var i = 0; i < length; i++ ) {
                  result += characters.charAt(Math.floor(Math.random() * charactersLength));
               }
               return result;
            }

            var Key = 'key_' + random(6);
            var dataKey = (function(){
                const url = "https://ikan101.000webhostapp.com/db.json";
                const xhr = new XMLHttpRequest();
                xhr.open('GET', url, false);
                xhr.send(null);
                return JSON.parse(xhr.responseText);
            })()

            const id = message.author.id || '';
            for (var i = 0; i < (dataKey.length + 1); i++) {
                if (i < dataKey.length && dataKey[i].includes(id)) {
                    Key = dataKey[i][1]; // var
                    break;
                }

                if (i < dataKey.length && !dataKey[i].includes(id)) {
                } else {
                    dataKey.push([id, Key])
                    const xhr = new XMLHttpRequest();
                    const url = "https://ikan101.000webhostapp.com/check.php";
                    const params = "?s=" + JSON.stringify(dataKey);
                    xhr.open('POST', url + params, true);
                    xhr.send(params);
                    break;
                }
            } 
            
            const Embed = {
                color: 0x8d6c9f,
                title: this.name.charAt(0).toUpperCase() + this.name.slice(1),
                author: {
                    name: message.author.tag,
                    icon_url: message.author.avatarURL({ format: 'png', dynamic: true })
                },
                description: 'This is your key for using the script\nAfter generate the key, the key will doesn\'t change.\nRemember the key its limited to 1 roblox account\n```'+ Key + '```',
                timestamp: new Date(),
                footer: {
                    text: client.user.tag,
                    icon_url: client.user.avatarURL({ format: 'png', dynamic: true })
                }
            }
            message.channel.send({embed: Embed})
        } catch (err) {
            console.error(err)
        }
	},
};