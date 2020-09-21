const AWS = require("aws-sdk")

const documentClient = new AWS.DynamoDB.DocumentClient();
exports.handler = async(event) => {
    const {obstaculos}  = event;
    const params = {
        TableName: "regreso_buzon",
        Item: {
            id: 1,
            fecha:parseInt((new Date()).toISOString().replace(/[^0-9]/g, "")),
            obstaculos: obstaculos
        }
    };
    try {
        const data = await documentClient.put(params).promise();
        return {
            error: false,
            message: 'regreso_buzon agregada',
            code: 200
        };
    } catch (er) {
        return {
            error: false,
            message: 'Hubo un problema al agregar la regreso_buzon',
            code: 502
        };
    }
};