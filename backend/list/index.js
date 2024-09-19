const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
    const bucket = process.env.BUCKET_NAME;

    const params = {
        Bucket: bucket,
    };

    try {
        const data = await s3.listObjectsV2(params).promise();
        const files = data.Contents.map(item => item.Key);
        return {
            statusCode: 200,
            body: JSON.stringify(files),
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message }),
        };
    }
};