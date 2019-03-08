"use strict"

var students = [
    {
        name: "john",
        voice: "Matthew",
        accuracy: 10,
        stubbornness: 20,
        mathAnswers: [
            'the answer is {0}',
            'easy enough, {0}',
            'is it {0} ?'
        ],
        nameAnswer: [
            'my name is john'
        ],
        correctAnswer: [
            "I can't beleive it!",
            "Horay!",
            "Yes!"
        ],
        incorrectAnswer: [
            'no way',
            'impossible',
            'darn it'
        ], 
        waitingAnswer : [
            'hmmmmmmmmm',
            'let me think'
        ]
            
    },
    {
        name: "max",
        voice: "Joey",
        accuracy: 60,
        stubbornness: 80,
        mathAnswers: [
            '{0}',
            '{0}?'
        ],
        nameAnswer: [
            'max'
        ],
        correctAnswer: [
            "I knew it"
        ],
        incorrectAnswer: [
            'no way',
            'impossible',
            'darn it'
        ],
        waitingAnswer : [
            'hmmmmmmmmm',
            'let me think'
        ]
        
    },
    {
        name: "linda",
        voice: "Ivy",
        accuracy: 100,
        stubbornness: 50,
        mathAnswers: [
            'not sure but I think it is {0}'
        ],
        nameAnswer: [
            'linda'
        ],
        correctAnswer: [
            "I knew it"
        ],
        incorrectAnswer: [
            'no way',
            'impossible',
            'darn it'
        ],
        waitingAnswer : [
            'hmmmmmmmmm',
            'let me think'
        ]
        
    }
]

module.exports = students