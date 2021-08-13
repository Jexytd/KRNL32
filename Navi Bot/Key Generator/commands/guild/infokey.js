const XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;

module.exports = {
	name: 'infokey',
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
            const id = message.author.id || '';
            const data = (function(){
                const url = "https://ikan101.000webhostapp.com/db.json";
                const xhr = new XMLHttpRequest();
                xhr.open('GET', url, false);
                xhr.send(null);
                return JSON.parse(xhr.responseText);
            })()
            
            for (var i = 0; i < (data.length + 1); i++) {
                if (i < data.length && data[i].includes(id)) {
                    const Key = data[i][1];
                    var uid = data[i][2] || 'Unregistered';
                    if (uid != 'Unregistered') {
                        uid = (function() {
                            const url = 'https://users.roblox.com/v1/users/' + uid;
                            const xhr = new XMLHttpRequest();
                            xhr.open('GET', url, false);
                            xhr.send();
                            return JSON.parse(xhr.responseText);
                        })()
                    }
                    Embed['description'] = '**Key**\n``' + Key + '``\n\n**UID**\n``' + `${(uid['id'] || 'Invalid uid')} / ${(uid['name'] || '???')}` + '``';
                    break;
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