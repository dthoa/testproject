// const getBlobDuration = require("get-blob-duration");
// const LexAudio = require("./aws-lex-audio")

var audioControl = new LexAudio.audioControl();
var userId = "";
var audio = null;
var sessionAttributes = "";
var RECORDED_AUDIO = 'recorded_audio';
var EXTRA_AUDIO = 'extra_audio';
var ANSWER_AUDIO = 'answer_audio';
var ANSWER_TEXT = 'answer_text';
var cache = {}
var ws = new WebSocket('ws://localhost:40510');


// event emmited when connected
ws.onopen = function () {
    console.log('websocket is connected ...')

    // sending a send event to websocket server
    //ws.send(JSON.stringify('connected'))
}

// event emmited when receiving message 
ws.onmessage = function (message) {
    console.log(message);
    try {
      var response = JSON.parse(message.data);
      if(response.header.statusCode !== 200) {
        playingEnded()
        return
      }
        
      switch(response.header.dataType) {
      case ANSWER_AUDIO:
        processAudioMessage(response)  
        break
      case EXTRA_AUDIO:
        playAudio(response.body.audio)  
        break
      }
    } catch (err) {
      console.log(err);
    }
}

function record() {
  console.log("Start Recording");

  //Start recording
  audioControl["isRecording"] = true;
  audioControl.startRecording(function() {
    
    //Stop recording temporarily
    console.log("Stop Recording");
    audioControl.stopRecording();
    audioControl["isRecording"] = false;
    //In case the server never response, it should enable recording again
    //setTimeout(playingEnded, 30*1000); // 10s
    
    console.log("Send Request to Server");
    sendRequest();
  }, null, {time: 1500, amplitude: 0.2});
}



function playingEnded() {
  if(!audioControl["isRecording"]) {
    console.log("Playing Ended");
    if(audio != null) {
      audio.removeEventListener('ended', playingEnded);
    }
    record();
  }
  
}

function sendRequest() {
  audioControl.exportWAV(function (blob) {

    //var fd = new FormData();
    //fd.append('soundBlob', blob, 'myfiletosave.wav');
    //fd.append('userId', userId);
    //fd.append('sessionAttributes', sessionAttributes)
    if(typeof userId === "undefined") {
      return;
    }

    getBlobDuration(blob).then(function(duration) {
        console.log('duration: ' + duration + ' seconds');
        if(duration >= 15) {
            console.log('question cannot be longer than 15 seconds')
            playingEnded()
            return
        }
        var reader = new FileReader();
        reader.readAsDataURL(blob); 
        reader.onloadend = function() {
            console.log(reader.result);
            var data = {
                header: {
                dataType: RECORDED_AUDIO,
                userId: userId,
                sessionAttributes: sessionAttributes
                },
                body: {
                audio: reader.result.split(",")[1],
                }
            }
            ws.send(JSON.stringify(data))
            }
        });
    //console.log(duration + ' seconds')

    
  }, 16000);
}

function processAudioMessage(response) {
  userId = response.header.userId
  sessionAttributes = response.header.sessionAttributes
  playAudio(response.body.audio, playingEnded)
}

function playAudio(audioData, playingEndedCallBack = null) {
  audio = new Audio();
  if (audio.canPlayType('audio/mpeg')) {
      audio.src = "data:audio/mpeg;base64," + audioData
      audio.play()
      if(playingEndedCallBack)
        audio.addEventListener('ended', playingEndedCallBack);
  }
}

function getBlobDuration(blob) {
    const tempVideoEl = document.createElement('video')
  
    const durationP = new Promise(resolve =>
      tempVideoEl.addEventListener('loadedmetadata', () => {
        // Chrome bug: https://bugs.chromium.org/p/chromium/issues/detail?id=642012
        if(tempVideoEl.duration === Infinity) {
          tempVideoEl.currentTime = Number.MAX_SAFE_INTEGER
          tempVideoEl.ontimeupdate = () => {
            tempVideoEl.ontimeupdate = null
            resolve(tempVideoEl.duration)
            tempVideoEl.currentTime = 0
          }
        }
        // Normal behavior
        else
          resolve(tempVideoEl.duration)
      })
    )
  
    tempVideoEl.src = window.URL.createObjectURL(blob)
  
    return durationP
  }
