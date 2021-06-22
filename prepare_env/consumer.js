var amqp = require('amqplib/callback_api');
var request = require('request');

amqp.connect('amqp://guest:guest@192.168.1.104', function (error0, connection) {
    if (error0) {
        throw error0;
    }
    connection.createChannel(function (error1, channel) {
        if (error1) {
            throw error1;
        }

        var queue = 'test';

        console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", queue);

        channel.consume(queue, function (msg) {
            console.log(" [x] %s: '%s'", msg.fields.routingKey, msg.content.toString());
            var data =JSON.parse(msg.content.toString())
            console.log(data);

            console.log(msg.content.toString());



            request.post({
                headers: { 'content-type': 'application/json' },
                url: 'http://192.168.1.104:9200/log-rest/_doc',
                body:  JSON.stringify({
                    'timestamp': data.timestamp,
                    'request_type': msg.fields.routingKey,
                    'data': JSON.stringify(data.data),
                    'status_code': data.statusCode,
                    'ip': data.ip
                 })

            }, function (error, response, body) {
                console.log(body);
            });

            console.log("=================================");
        }, {
            noAck: true
        });
    });
});
