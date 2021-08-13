const { Client, MessageEmbed, Collection } = require('discord.js');
const { Token,Prefix } = require('./config.json');
//const XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
const fetch = require('node-fetch');
const fs = require('fs');
const client = new Client();

// garbage //
client.commands = new Collection();
client.auto = new Collection();
client.cd = new Collection();

client.on('ready', () => {
    console.log('Log on as ', client.user.tag);
    client.auto.get().execute(client)
});

// command handler
const path = './commands'
fs.readdir(path, (err, files) => {
    if (err) console.error(err);
    const js = files.filter(f => f.split(".").pop() === "js");
    js.forEach(f => {
        const cmd = require(path + `/${f}`);
        console.log('[AUTO]', f, 'loaded!')
        client.auto.set(cmd.name, cmd)
    })

    const folder = files.filter(f => f == f.split("."))
    folder.forEach(f => {
        if (fs.statSync(path + `/${f}`)) {
            fs.readdir(path + `/${f}`, (e, sf) => {
                const js = sf.filter(f => f.split(".").pop() === "js");
                js.forEach(f2 => {
                    const cmd = require(path + `/${f}/${f2}`);
                    console.log('[' + f.charAt(0).toUpperCase() + f.slice(1) +']', f2, 'loaded!')
                    client.commands.set(cmd.name, cmd)
                })
            })
        }
    })
})

client.on('message', (message) => {
    if (!message.content.startsWith(Prefix) || message.author.bot) return;
    const args = message.content.slice(Prefix.length).trim().split(/ +/)
    const command = args.shift().toLowerCase();

    const commands = client.commands.get(command) || client.commands.find(c => c.aliases && c.aliases.includes(command))
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

    if (!commands) return;
    Embed['title'] = command.charAt(0).toUpperCase() + command.slice(1);

    const { cd } = client;

    if (!cd.has(commands.name)) {
        cd.set(commands.name, new Collection())
    }

    const now = Date.now()
    const timestamps = cd.get(commands.name)
    const cooldownAmount = (commands.cd || 6) * 1000

    if (timestamps.has(message.author.id)) {
        const expirationTime = timestamps.get(message.author.id) + cooldownAmount

        if (now < expirationTime) {
            const timeLeft = (expirationTime - now) / 1000
            return message.reply('Bruh calm down, you type commands too fast. please wait **' + Math.floor(timeLeft.toFixed(1)) + 's** after using commands')
        }
    }

    timestamps.set(message.author.id, now)
    setTimeout(() => timestamps.delete(message.author.id), cooldownAmount)

    if (commands.dm && message.channel.type !== 'dm') {
        Embed['description'] = "Please run this `" + `${Prefix}${command}${(commands.usage && ' ' + commands.usage) || ''}` + "` on dms!"
        return message.channel.send({embed: Embed});
    }
    if (commands.guilds && message.channel.type === 'dm') {
        Embed['description'] = "Please run this `" + `${Prefix}${command}${(commands.usage && ' ' + commands.usage) || ''}` + "` on guilds!"
        return message.channel.send({embed: Embed});
    }

    try {
        commands.execute(message, args, client)
    } catch (e) {
        console.error(e)
        Embed['description'] = 'There was an error when trying execute that command!'
        message.channel.send({embed: Embed});
    }
});

client.login(Token);