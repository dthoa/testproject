var Student = require("./student")

var Classroom = function (students) {
    function detectStudent(query) {
        for (let i = 0; i < students.length; i++) {
            let student = students[i];
            if (query.toLowerCase().startsWith(student.name) || query.toLowerCase().startsWith(`hey ${student.name}`)) {
                return {
                    student: new Student(student),
                    question: query.toLowerCase().startsWith(student.name) ? query.substr(student.name.length) : query.substr(student.name.length + 4),
                };
            }
        }
        return null;
    }

    function detectStudentByName(studentName) {
        for (let i = 0; i < students.length; i++) {
            let student = students[i];
            if (student.name == studentName) {
                return {
                    student: new Student(student),
                    //question: query.toLowerCase().startsWith(student.name) ? query.substr(student.name.length) : query.substr(student.name.length + 4),
                };
            }
        }
        return null;
    }

    function getARandomStudent() {
        var index = Math.floor(Math.random() * students.length)
        return new Student(students[index])
    }

    function findStudentByUserId(userId) {
        var userParts = userId.split('-')
        if (userParts.length == 3 && userParts[1].length > 0) {
            let studentName = userParts[1]
            var index = students.findIndex(x => x.name.toLowerCase() === studentName.toLowerCase())
            return index >= 0 ? new Student(students[index]) : null;
        }
        return null;
    }

    function getNewUserId(studentName) {
        let time = new Date().getTime()
        return `class-${studentName.toLowerCase()}-${time}`
    }

    function getStudentNames() {
        return students.map(t=>t.name);
    }

    return {
        detectStudent,
        findStudentByUserId,
        getNewUserId,
        getStudentNames,
        getARandomStudent,
        detectStudentByName
    }
}

module.exports = Classroom;