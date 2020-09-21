const AWS = require("aws-sdk")

const documentClient = new AWS.DynamoDB.DocumentClient();
exports.handler = async(event) => {
    const {peso}  = event;
    const params = {
        TableName: "salida_buzon",
        Item: {
            id: 1,
            fecha:parseInt((new Date()).toISOString().replace(/[^0-9]/g, "")),
            peso: peso
        }
    };
    try {
        const data = await documentClient.put(params).promise();
        return {
            error: false,
            message: 'salida_buzon agregada',
            code: 200
        };
    } catch (er) {
        return {
            error: false,
            message: 'Hubo un problema al agregar la salida_buzon',
            code: 502
        };
    }
};