const {Client} = require('discord.js');
const { Token } = require('../token.json');
const fs = require('fs');
const client = new Client();

var userId = ''

client.on('ready', () => {
	console.log(`Log on as ${client.user.tag}`)
})

client.on('message', (message) => {
	let getuserid = function() {return message.author.id != '518759221098053634' ? message.author.id : false}()
	if (getuserid) { userId = getuserid }
	if (message.author.id == '518759221098053634') {
		message.embeds.forEach((embed) => {
			try {
				const Quiz = require("./quiz.json");
				var d = new Date();
				var r = d.toLocaleTimeString();
				const title = embed.title
				if (title == "Quiz") {
					console.log(Quiz .length)
					const fields = embed.fields;
					const name = fields[0].name;
					const value = fields[0].value;
					const question = name.substring(2, name.length - 2)

					for (const q of Quiz) {
						if (q[0] == question) {
							var data_answer = q[1];
							if (value.search(data_answer)) {
								var foundanswer = value.search(data_answer); // **[A]** answer
								var get_choice = value.substring(foundanswer - 6, foundanswer - 3);
								message.channel.send('<@'+ userId +'>, The answer of question is **'+ get_choice +'**');
								console.log(`[${r}]`, 'Question: '+ question);
								console.log(`[${r}]`, 'Answer:' + get_choice);
								console.log(`[${r}]`, 'Indexs:' + foundanswer);
								console.log(`[${r}]`, 'Z:' + (foundanswer - 6) + ' X:' + (foundanswer - 3));
								return
							}

						}
					}

					for (idx = 0; idx < (Quiz.length + 1); idx++) {
						if (Quiz.includes(Quiz[idx])) {
						} else {
							Quiz.push([question, ""])
							fs.writeFile(
							    './quiz.json',
							    JSON.stringify(Quiz, null, 1),
							    function (err) {
							        if (err) {
							            console.error('Crap happens');
							        }
							    }
							)
							console.log(`[${r}]`, 'Data Saved!')
							break
						}
					}
				}
			} catch (e) {
				console.error(`[${r}]`, e)
			}
	    });
	}
})

client.login(Token);