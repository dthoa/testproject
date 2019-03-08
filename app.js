"use strict"

const express = require("express")
const bodyParser = require("body-parser")
const students = require("./config/students")
const Classroom = require("./model/classroom");
const app = express()
const polly = require("./polly")();
const multer = require("multer")();
const queryService = require("./services/queryService");
const ws = require("./services/websocket.js");

var classroom = new Classroom(students);
global.classroom = classroom;
global.wsClients = {}
app.use(express.static('client'))
app.use(bodyParser.urlencoded({
    extended: true
}))
app.use(bodyParser.json())
global.voiceCache = {}
global.currentStudent = null

function say(res, voice, answer, headers) {
    
    var header = {
        'Content-Type': 'plain/text'
    }
    if (headers) {
        for (prop in headers) {
            header[prop] = headers[prop]
        }
    }

    if (answer && answer.length == 0) {
        res.set(header)
        res.end();
    }
    
    polly.say(voice, answer).then(data => {
        res.set(header);
        res.write(data.AudioStream.toString("base64"))
        res.end();
    })
}

function transcribeCompleted(transcribeContext) {
    console.log(transcribeContext.success);
    if (transcribeContext.success) {

        console.log(transcribeContext.question);

        let studentResult = classroom.detectStudent(transcribeContext.question);
        let sessionAttributes = transcribeContext.sessionAttributes || [] ;
        let student, question, userId;

        if (!studentResult) {
            if (transcribeContext.userId.length > 0) {
                student = classroom.findStudentByUserId(transcribeContext.userId);
                userId = transcribeContext.userId;
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
        //currentStudent = student
        if (student != null) {
            student.answerQuestion(question, userId, sessionAttributes)
            .then(data => {
                if (data.sessionAttributes) {
                    sessionAttributes.push(data.sessionAttributes)
                }
                var newStudent = student;
                var newUserId = userId;
                if(data.student) {
                    newStudent = data.student;
                    newUserId = classroom.getNewUserId(newStudent.name);
                }
                say(transcribeContext.response, newStudent.voice, data.answer, {
                    userId: newUserId,
                    sessionAttributes: JSON.stringify(sessionAttributes)
                })
            }) 
        }
    } else {
        transcribeContext.response.status(400).end();
    }
}

app.post("/audioCommand", multer.single('soundBlob'), function (req, res) {

    
    let requestContext = {
        query: req.file.buffer.toString("base64"),
        userId: req.body.userId || "",
        sessionAttributes: req.body.sessionAttributes ? JSON.parse(req.body.sessionAttributes) : "",
        studentNames: classroom.getStudentNames(),
        response: res
    }



    queryService.askGoogle(requestContext).then(data => {
        transcribeCompleted(data)
    }).catch(err => {
        console.log(err)
        transcribeContext.response.status(400).end();
    })
})

// app.get('/', function (req, res) {
//     res.sendFile(__dirname + '/index.html');
// })

app.listen(9999, function (data) {
    console.log("server is started on port 3000")
})



