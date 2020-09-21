const AWS = require("aws-sdk")
const documentClient = new AWS.DynamoDB.DocumentClient();
exports.handler = function(event, ctx, callback) {
    const params = {
        TableName: "regreso_buzon",
        ScanIndexForward: "false",
        Limit: 5,
        KeyConditionExpression : "#id = :id",
        ExpressionAttributeNames: {
        "#id":"id"},
        ExpressionAttributeValues : {
            ':id' : 1
        }
    };
    documentClient.query(params, function(err, data){
        if(err){
            callback(err, null);
        }else{
            callback(null, data);
        }
    });
}