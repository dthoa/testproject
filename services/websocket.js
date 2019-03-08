"use strict"
var ws = require('ws')
const students = require("../config/students")
const Classroom = require("../model/classroom");
const polly = require("../polly")();
const queryService = require("./queryService");
const WsResponse = require("./ws-response");


var WebSocket = function() {
    let RECORDED_AUDIO = 'recorded_audio'
    let EXTRA_AUDIO = 'extra_audio'
    let ANSWER_AUDIO = 'answer_audio'
    let ANSWER_TEXT = 'answer_text'

    var WebSocketServer = ws.Server
    var wsServer = new WebSocketServer({port: 40510})

    wsServer.on('connection', function (ws) {
        ws.on('message', function (message) {
            console.log('received data')
            try{
                var wsRequest = JSON.parse(message)
                var wsResponse = WsResponse(wsRequest, ws)
                                
                switch(wsRequest.header.dataType) {
                    case RECORDED_AUDIO:
                        let requestContext = {
                            query: wsRequest.body.audio,
                            userId: wsRequest.header.userId || "",
                            sessionAttributes: wsRequest.header.sessionAttributes || "",
                            studentNames: classroom.getStudentNames(),
                            response: "",
                            wsResponse: wsResponse,
                            contentType: "audio/l16; rate=16000; channels=1",
                            //contentType: "text/plain;charset=utf-8",
                            googleFlag: true,
                            awsFlag: true
                        }
                        //askGoogle(requestContext)
                        askAws(requestContext)
                        break
                    default:
                        break
                }
            } catch (err) {
                console.log(err);  
            }
        })

        ws.on('close', function(connection) {
            console.log('Connection Closed');
            console.log(connection);
        });
    })

    function askGoogle(requestContext) {
        queryService.askGoogle(requestContext)
        .then(data => {
            requestContext.googleFlag = true
            if(requestContext.awsFlag) {
                requestContext.googleFlag = false
                googleTranscribeCompleted(data)
            } else {
                //Wait
            }
        })
        .catch(err => {
            console.log(err)
        })
    }

    function askAws(requestContext) {
        queryService.askAws(requestContext)
        .then(data => {
            console.log(data)
            var transcribeContext = {
                requestContext: requestContext,
                transcribeData: data,
                success: true,

            }
            try {
                awsTranscribeCompleted(transcribeContext)
            } catch(e) {
                console.log(e)
                requestContext.wsResponse.sendEmptyResponse()
            }
            
        }).catch(err => {
            console.log(err)
            requestContext.wsResponse.sendEmptyResponse()
        });
    }

    function googleTranscribeCompleted(transcribeContext) {
        var requestContext = transcribeContext.requestContext
        var wsResponse = requestContext.wsResponse
        if (transcribeContext.success) {
    
            console.log(transcribeContext.question);
    
            let studentResult = classroom.detectStudent(transcribeContext.question);
            let sessionAttributes = requestContext.sessionAttributes || [] ;
            let student, question, userId;
    
            if (!studentResult) {
                if (requestContext.userId.length > 0) {
                    student = classroom.findStudentByUserId(requestContext.userId);
                    userId = requestContext.userId;
                } else {
                    // get a random student
                    student = classroom.getARandomStudent()
                    userId = classroom.getNewUserId(student.name)
                }
                question = transcribeContext.question;
            } else{
                student = studentResult.student;
                userId = classroom.getNewUserId(studentResult.student.name);
                question = studentResult.question;
            } 
            wsResponse.ws.currentStudent = student
            currentStudent = student
            if (student != null) {
                student.answerQuestion(question, userId, sessionAttributes)
                .then(data => {
                    if(typeof data.answer === 'undefined') {
                        data.answer = "I'm not sure"
                    }
                    if (data.sessionAttributes) {
                        sessionAttributes.push(data.sessionAttributes)
                    }
                    var newStudent = student;
                    var newUserId = userId;
                    if(data.student) {
                        newStudent = data.student;
                        newUserId = classroom.getNewUserId(newStudent.name);
                    }
                    queryService.say(wsResponse, newStudent.voice, data.answer, {
                        userId: newUserId,
                        sessionAttributes: sessionAttributes,

                        dataType: ANSWER_AUDIO
                    })
                }).catch(err => {
                    queryService.say(wsResponse, student.voice, "I'm not sure", {
                        userId: userId,
                        sessionAttributes: sessionAttributes,
                        dataType: ANSWER_AUDIO
                    })
                })   
            }
        } else {
            queryService.say(wsResponse, '', "", '')
            //transcribeContext.response.status(400).end();
        }
    }

    function awsTranscribeCompleted(transcribeContext) {
        var requestContext = transcribeContext.requestContext
        var wsResponse = requestContext.wsResponse
        
        if (transcribeContext.success) {
            var inputTranscript = transcribeContext.transcribeData.inputTranscript

            console.log(inputTranscript);
            let sessionAttributes = requestContext.sessionAttributes || [] ;
            let student, userId;

            // Find an existing student or create a new student
            if(transcribeContext.transcribeData.intentName == "NameIntent") {
                student = classroom.getARandomStudent()
                userId = classroom.getNewUserId(student.name)
            } else {
                let studentResult = null
                var intentName = transcribeContext.transcribeData.intentName
                if(intentName ==  "MathIntent"){
                    var studentName = transcribeContext.transcribeData.slots.nameSlot;
                    if (studentName) {
                        studentResult = classroom.detectStudentByName(studentName.toLowerCase());    
                    }
                } else {
                    studentResult = classroom.detectStudent(inputTranscript);
                }
                
                if (!studentResult) {
                    if (requestContext.userId.length > 0) {
                        student = classroom.findStudentByUserId(requestContext.userId);
                        userId = requestContext.userId;
                    } else {
                        // get a random student
                        student = classroom.getARandomStudent()
                        userId = classroom.getNewUserId(student.name)
                    }
                    //question = transcribeContext.question;
                } else{
                    student = studentResult.student;
                    userId = classroom.getNewUserId(studentResult.student.name);
                    //question = studentResult.question;
                } 
            }

            wsResponse.ws.currentStudent = student
            currentStudent = student
            if (student != null) {
                var result = student.processResponse(transcribeContext.transcribeData)
                if(typeof result.answer === 'undefined') {
                    result.answer = "Sorry, can you please repeat that?"
                }
                if (result.sessionAttributes) {
                    sessionAttributes.push(result.sessionAttributes)
                }
                var newStudent = student;
                var newUserId = userId;
                if(result.student) {
                    newStudent = result.student;
                    newUserId = classroom.getNewUserId(newStudent.name);
                }
                console.log("Answer: " + result.answer)
                queryService.say(wsResponse, newStudent.voice, result.answer, {
                    userId: newUserId,
                    sessionAttributes: sessionAttributes,
                    dataType: ANSWER_AUDIO
                })
            }
        } else {
            console.log("There some error, no answer")
            queryService.say(wsResponse, '', "", '', {})
        }
    }

    // function say(wsResponse, voice, answer, headerInfo) {
        
    //     if ((!answer) || (answer.length == 0)) {
    //         wsResponse.header.dataType = ''
    //         wsResponse.header.statusCode = 400
    //         wsResponse.body = ''
    //         wsResponse.send()
    //         return
    //     }

    //     // Check if the voice is already in DB


    //     polly.say(voice, answer).then(data => {
    //         wsResponse.header = headerInfo
    //         wsResponse.header.statusCode = 200
    //         wsResponse.body = {
    //             text: answer, 
    //             audio: data.AudioStream.toString("base64")
    //         }
    //         wsResponse.send()

    //         // requestContext.res.set(header);
    //         // requestContext.res.write(data.AudioStream.toString("base64"))
    //         // requestContext.res.end();
    //     })
    // }

    var publicApis = {
        RECORDED_AUDIO: RECORDED_AUDIO,
        EXTRA_AUDIO: EXTRA_AUDIO,
        ANSWER_TEXT: ANSWER_TEXT,
        ANSWER_AUDIO: ANSWER_AUDIO
    }
    return publicApis
}

module.exports = WebSocket();

