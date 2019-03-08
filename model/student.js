var queryService = require("../services/queryService")

var Student = function (config) {

    function _answerMathQuestion(firstOp, secondOp, operation) {
        var op = operation.toLowerCase()
        var correctAnswer = (op == "multiply" || op == "times" || op == "by" || op == "multiplied by") ? firstOp * secondOp :
            (op == "divide" || op == "divided by") ? firstOp / secondOp :
            op == "plus" ? firstOp + secondOp :
            op == "minus" ? firstOp - secondOp : 0

        if (Math.random() * 100 <= config.accuracy) {
            return correctAnswer
        } else {
            return correctAnswer + Math.floor(Math.random() * 3)
        }
    }

    function processResponse(data) {

        var result = {
            sessionAttributes: data.intentName
        }

        if (data.intentName == "MathIntent") {
            let firstOp = parseInt(data.slots.firstOp)
            let secondOp = parseInt(data.slots.secondOp)

            var answer = _answerMathQuestion(firstOp, secondOp, data.slots.operation)

            var index = Math.floor(Math.random() * config.mathAnswers.length)
            result.answer = config.mathAnswers[index].replace("{0}", answer)            

        }
        else if (data.intentName == "CorrectIntent") {
            var index = Math.floor(Math.random() * config.correctAnswer.length)
            result.answer = config.correctAnswer[index]
        }
        else if (data.intentName == "IncorrectIntent") {
            var index = Math.floor(Math.random() * config.incorrectAnswer.length)
            result.answer = config.incorrectAnswer[index]
        }
        else if (data.intentName == "NameIntent") {
            var index = Math.floor(Math.random() * config.nameAnswer.length)
            result.answer = config.nameAnswer[index]
        }
        return result;
    }

    function answerQuestion(query, userId, sessionAttributes) {
        return new Promise((resolve, reject) => {
            if (!query || query.length == 0) {
                resolve({ answer: ""})
            } else {
                requestContext = {
                    query: query,
                    userId: userId,
                    sessionAttributes: sessionAttributes,
                    contentType: 'text/plain; charset=utf-8'
                }
                queryService.askAws(requestContext).then(data => {
                    var answer;
                    if(data.intentName == 'NameIntent') {
                        //Create a new student
                        var newStudent = global.classroom.getARandomStudent();
                        answer = newStudent.processResponse(data);
                        answer.student = newStudent;
                    } else {
                        answer  = processResponse(data)
                    }
                    resolve(answer)
                }).catch(err => {
                    reject(err)
                })   
            }
        })
    }

    var publicAPI =  {
        answerQuestion,
        processResponse
    }

    for (prop in config) {
        publicAPI[prop] = config[prop]
    }

    return publicAPI
}
module.exports = Student