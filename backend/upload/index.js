const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
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
            body: JSON.stringify({ message: 'File uploaded successfully!' }),
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message }),
        };
    }
};
