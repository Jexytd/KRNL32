const {Prefix} = require('../config.json');
const ms = require('ms');
const luamin = require('luamin');

module.exports = {
    execute(client) {
        client.on('message', message => {
            if (message.author.bot || message.channel.type !== 'dm') return;

            const args = message.content.slice(Prefix.length).trim().split(/ +/)
            const command = args.shift().toLowerCase();
            const Embed = {
                color: 0x8d6c9f,
                title: '',
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

            let options = [];
            var iscollected = false;
            var step = 1;

            if (command == 'obfuscate') {
                if (step == 1) {
                    Embed['title'] = 'Step ' + step + '/3';
                    message.channel.send({embed: Embed}).then(msg => {
                        const emo = ['👍', '👎'];
                        for (var i = 0; i < emo.length; i++) {
                            msg.react(emo[i]);
                        }

                        const filter = (reaction, user) => {
                            return emo.includes(reaction.emoji.name) && user.id === message.author.id;
                        }

                        msg.awaitReactions(filter, { max: 1, time: 5000, errors: ['time'] })
                        .then(collected => {
                            const reaction = collected.first();
                            if (reaction.emoji.name == emo[0]) {
                                step += 1
                                ok();
                            } else {
                                message.channel.send('Stopping commands...');
                            }
                        })
                        .catch(collected => {
                            console.log("Time's up");
                        })
                    })
                }

                function ok() {
                    Embed['title'] = 'Step ' + step + '/3';
                    Embed['description'] = '**Options:**\n1️⃣ `String Encryption` Secures string in bytecode\n2️⃣ `Junk Code` Just like the name, doesn\'t cause performance loss\n\nAfter select options send file that you want obfuscate!'
                    message.channel.send({embed: Embed}).then(msg => {
                        const emo = ['0️⃣', '1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '6️⃣', '7️⃣', '8️⃣', '9️⃣']
                        msg.react('1️⃣').then(() => {msg.react('2️⃣')})
    
                        const filter = (reaction, user) => {
                            return emo.includes(reaction.emoji.name) && user.id === message.author.id;
                        }
    
                        const collector = msg.createReactionCollector(filter, { time: ms('20s') });
                        var index = 1;

                        collector.on('collect', (reaction, user) => {
                            console.log(`Collected ${reaction.emoji.name} from ${user.tag}`);
                            options.push(index);
                            index++
                        });
                        
                        collector.on('end', collected => {
                            console.log(`Period time has ended. Collected ${collected.size} items indexed is ${options.length}`);
                            iscollected = true;
                        });
                    })
                }
            }      
        })
    }
}