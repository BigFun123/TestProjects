exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));

    const fetchUrl = process.env.FETCH_URL;
    console.log('Fetching data from URL:', fetchUrl);
    const result = await fetch(fetchUrl);
    const json = await result.json();
    console.log('Fetched result:', json);

    return {
        statusCode: 200,
        body: JSON.stringify({ message: 'Hello from Node.js Lambda!', json })
    };
};
