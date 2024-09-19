import AWS from 'aws-sdk';
const s3 = new AWS.S3();

export const handler = async (event) => {
    const fileContent = Buffer.from(event.body, 'base64');
    const bucket = process.env.BUCKET_NAME;
    const fileName = event.queryStringParameters.fileName;

    const params = {
        Bucket: bucket,
        Key: fileName,
        Body: fileContent,
    };

    try {
        await s3.putObject(params).promise();
        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*', // Permite requisições de qualquer origem
                'Access-Control-Allow-Headers': 'Content-Type', // Permite cabeçalhos específicos
                'Access-Control-Allow-Methods': 'POST', // Permite o método POST
            },
            body: JSON.stringify({ message: 'File uploaded successfully!' }),
        };
    } catch (error) {
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
            },
            body: JSON.stringify({ error: error.message }),
        };
    }
};