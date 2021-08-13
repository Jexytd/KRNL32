const XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
const {Prefix} = require('../../config.json');

module.exports = {
	name: 'setuid',
    usage: '[userid]',
	description: 'Set key roblox userid',
    guilds: true,
	execute(message, args, client) {
        const Embed = {
            color: 0x8d6c9f,
            title: this.name.charAt(0).toUpperCase() + this.name.slice(1),
            author: {
                name: message.author.tag,
                icon_url: message.author.avatarURL({ format: 'png', dynamic: true })
            },
            description: '',
            timestamp: new Date(),
            footer: {
                text: client.user.tag,
                icon_url: client.user.avatarURL({ format: 'png', dynamic: true })
            }
        }

        try {  
            const id = message.author.id;
            var uid = Number(args[0]);
            if (!uid || uid <= 0 || uid >= 10000000000 || uid >= NaN) {
                Embed['description'] = 'Please use this commands correctly.\nUsage: `' + `${Prefix}${this.name} ${this.usage}` + '`'
                message.channel.send({embed: Embed});
                return;
            }
            uid = String(uid);

            const data = (function(){
                const url = "https://ikan101.000webhostapp.com/db.json";
                const xhr = new XMLHttpRequest();
                xhr.open('GET', url, false);
                xhr.send(null);
                return JSON.parse(xhr.responseText);
            })()

            function sendData(dat) {
                const url = "https://ikan101.000webhostapp.com/check.php";
                const params = "?s=" + JSON.stringify(dat);
                const xhr = new XMLHttpRequest();
                xhr.open("POST", url + params, false);
                xhr.send(params);
            }

            for (var i = 0; i < (data.length + 1); i++) {
                if (i < data.length && data[i].includes(id)) {
                    if (data[i].length < 2) {
                        data[i].push(uid);
                        sendData(data);
                        Embed['description'] = 'You linked userid on key has been added with: ```' + data[i][2] + '```'
                        break;
                    } else {
                        data[i][2] = uid;
                        sendData(data);
                        Embed['description'] = 'You linked userid on key has been set with: ```' + data[i][2] + '```'
                        break;
                    }
                }

                if (i < data.length && !data[i].includes(id)) {
                } else {
                    Embed['description'] = 'Couldn\'t find `' + id + '` on data.\nPlease generate a key with commands `-getkey`'
                    break;
                }
            }

            message.channel.send({embed: Embed});
        } catch(e) {
            console.error(e)
        }
	},
};