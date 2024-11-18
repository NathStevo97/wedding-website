'use strict';

const AUTH_USERNAME = "admin"; // Replace with your username
const AUTH_PASSWORD = "password"; // Replace with your password
const ASSET_FILE_EXTENSIONS = [".css", ".png", ".jpg", ".js", ".ico", ".svg", ".woff2"]; // Static assets

exports.handler = async (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;

    // Bypass authentication for static assets
    if (ASSET_FILE_EXTENSIONS.some(ext => request.uri.endsWith(ext))) {
        return callback(null, request);
    }

    // Check Authorization header
    const authHeader = headers.authorization ? headers.authorization[0].value : null;
    if (authHeader) {
        const encodedCredentials = authHeader.split(" ")[1];
        const credentials = Buffer.from(encodedCredentials, "base64").toString("utf-8");
        const [username, password] = credentials.split(":");

        if (username === AUTH_USERNAME && password === AUTH_PASSWORD) {
            // Allow the request
            return callback(null, request);
        }
    }

    // Deny access for unauthenticated users
    const response = {
        status: "401",
        statusDescription: "Unauthorized",
        headers: {
            "www-authenticate": [{
                key: "WWW-Authenticate",
                value: "Basic realm=\"Protected Area\""
            }],
            "content-type": [{
                key: "Content-Type",
                value: "text/plain"
            }]
        },
        body: "Unauthorized",
    };

    callback(null, response);
};
