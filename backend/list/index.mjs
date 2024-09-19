import AWS from 'aws-sdk';
const s3 = new AWS.S3();

export const handler = async (event) => {
    const bucket = process.env.BUCKET_NAME;

    const params = {
        Bucket: bucket,
    };

    try {
        const data = await s3.listObjectsV2(params).promise();
        const files = data.Contents.map(item => item.Key);
        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET',
            },
            body: JSON.stringify(files),
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