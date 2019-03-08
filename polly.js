const AWS = require("aws-sdk")
const config = require("./config/config")

var Polly = function () {
    const polly = new AWS.Polly({
        accessKeyId: config.secrets.AWSAccessKeyId,
        secretAccessKey: config.secrets.AWSSecretKey,
        region: config.secrets.AWSRegion
    });

    function say(personName, textToSay) {
        return polly.synthesizeSpeech({
            OutputFormat: 'mp3',
            Text: `<speak>${textToSay}</speak>`,
            TextType: "ssml",
            VoiceId: personName,
        }).promise()
    }

    return {
        say: say
    }
}

module.exports = Polly