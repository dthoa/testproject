"use strict"
//const streamBuffers = require('stream-buffers');
const AppDAO = require('../database/dao')  
const VoiceRepository = require('../database/voice_repository')  

var QueryService = function() {

    const AWS = require("aws-sdk")
    const config = require("../config/config")
    const request = require("request")
    const polly = require("../polly")();
    

    const dao = new AppDAO('./database/database.sqlite3')
    const voiceRepo = new VoiceRepository(dao)
    voiceRepo.createTable().catch(
        err => {console.log(err)} 
    )

    let lexruntime = new AWS.LexRuntime({
        accessKeyId: config.secrets.AWSAccessKeyId,
        secretAccessKey: config.secrets.AWSSecretKey,
        region: config.secrets.AWSRegion
    });

    function askAws(requestContext) {
        //Convert base64 back to audio format
        var aBuffer = Buffer.from(requestContext.query, 'base64');
        //var blob = new Blob([buffer], {type: "application/octet-stream"});//application/octet-stream //audio/wav

        //Create stream from buffer
        const { Readable } = require('stream');
        const stream = new Readable();
        stream.push(aBuffer);
        stream.push(null);

        var params = {
            botAlias: '$LATEST',
            botName: 'Classroom',
            inputStream: stream,
            accept: 'audio/mpeg',
            contentType: requestContext.contentType
        }

        if (requestContext.userId) {
            params.userId = requestContext.userId
        } else {
            params.userId = "userId123"
        }

        if (requestContext.sessionAttributes) {
            //params.sessionAttributes = { context: JSON.stringify(requestContext.sessionAttributes)}
        }

        return lexruntime.postContent(params).promise()
    }
    
    function askGoogle(requestContext) {
        var payload = {
            config: {
                encoding: "LINEAR16",
                languageCode: "en-US",
                speechContexts: [{
                    phrases: requestContext.studentNames
                }]
            },
            audio: {
                content: requestContext.query
            }
        }
        var options = {
            uri: `https://speech.googleapis.com/v1/speech:recognize?key=${config.secrets.googleAPI}`,
            method: 'POST',
            json: payload
        }

        request(options, function(err, resp, body) {
            
            var googleResult = {
                success: resp != null && resp.statusCode == 200 && body.results !== undefined,
                //userId: requestContext.userId,
                //sessionAttributes: requestContext.sessionAttributes,
                //response: requestContext.response,
                requestContext: requestContext
            } 
            
            if (googleResult.success) {
                let question = body.results[0].alternatives[0].transcript;
                question = question.replace(" X ", " * ").replace("*", "multiply").replace("/", "divide").replace("+", "plus").replace("-", "minus").trim()
                googleResult.question = question
            }
            return new Promise((resolve, reject) => {
                googleResult.success ? resolve(googleResult) : reject(err)
            })
        });
    }

    function say(wsResponse, voice, answer, headerInfo) {
        wsResponse.header = headerInfo
        wsResponse.header.statusCode = 200

        // Check if the voice is already in DB
        voiceRepo.getByNameAndText(voice, answer)
        .then(voiceObj => {
            if(voiceObj) {
                console.log("Voice cache found")
                wsResponse.body = {
                    text: answer, 
                    audio: voiceObj.audio
                }
                wsResponse.send()
            } else {
                polly.say(voice, answer).then(data => {
                    var voiceAudio = data.AudioStream.toString("base64")
                    voiceRepo.create(voice, answer, voiceAudio).catch( err => console.log(err))
                    wsResponse.body = {
                        text: answer, 
                        audio: voiceAudio
                    }
                    wsResponse.send()
                }).catch(err => console.log(err))
            }
        })
        .catch(err => {
            console.log(err)
        })

        
    }

    var public_API = {
        askAws: askAws,
        askGoogle: askGoogle,
        say: say
    }

    return public_API;
}

module.exports = QueryService();
