const AWS = require("aws-sdk")

const documentClient = new AWS.DynamoDB.DocumentClient();
exports.handler = async(event) => {
    const {ubicacion}  = event;
    const {estado} = event;
    const params = {
        TableName: "ubicacion",
        Item: {
            id: 1,
            fecha:parseInt((new Date()).toISOString().replace(/[^0-9]/g, "")),
            ubicacion_actual: ubicacion,
            estado_actual: estado
        }
    };
    try {
        const data = await documentClient.put(params).promise();
        return {
            error: false,
            message: 'ubicacion agregada',
            code: 200
        };
    } catch (er) {
        return {
            error: false,
            message: 'Hubo un problema al agregar la ubicacion',
            code: 502
        };
    }
};