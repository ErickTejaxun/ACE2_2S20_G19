const AWS = require("aws-sdk")

const documentClient = new AWS.DynamoDB.DocumentClient();
exports.handler = async(event) => {
    const {peso}  = event;
    const {obstaculos} = event;
    const params = {
        TableName: "paquete_entregado",
        Item: {
            id: 1,
            fecha:parseInt((new Date()).toISOString().replace(/[^0-9]/g, "")),
            peso: peso,
            obstaculos: obstaculos
        }
    };
    try {
        const data = await documentClient.put(params).promise();
        return {
            error: false,
            message: 'paquete_entregado agregado',
            code: 200
        };
    } catch (er) {
        return {
            error: false,
            message: 'Hubo un problema al agregar el paquete_entregado',
            code: 502
        };
    }
};