function WsResponse(wsRequest, wsClient) {
    var header = {
        statusCode: 0,
        dataType: ''
    }
    var body = {
        text: '',
        audio: ''
    }
    var ws = wsClient
    var currentStudent = null

    if(wsRequest) {
        header = wsRequest.header
    }
    
    function send() {
        var responseData = {header: this.header, body: this.body}
        ws.send(JSON.stringify(responseData))
    }

    function sendEmptyResponse() {
        var responseData = {header: {dataType: '', statusCode: 400}, body: ''}
        ws.send(JSON.stringify(responseData))
        
    }
    return {
        header: header,
        body: body,
        send: send,
        currentStudent: currentStudent, 
        ws: ws,
        sendEmptyResponse: sendEmptyResponse
    }
}

module.exports = WsResponse