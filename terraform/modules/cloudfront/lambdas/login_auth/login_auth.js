'use strict';

const fs = require('fs');
const path = require('path');

// Load the configuration file at the start of the Lambda function
const config = require('./config.json');

// Replace with your desired password
const PASSWORD = config.site_password;
const LOGIN_PAGE = "/login.html";
const INDEX_PAGE = "/index.html";
const AUTH_COOKIE_NAME = "auth_token";
const AUTH_COOKIE_VALUE = "authenticated";

// Utility to generate an HTTP response
function generateResponse(status, statusDescription, headers, body) {
    return {
        status: status.toString(),
        statusDescription: statusDescription,
        headers: headers,
        body: body,
    };
}

// Helper function to determine MIME type
function getMimeType(extension) {
    const mimeTypes = {
        '.html': 'text/html',
        '.css': 'text/css',
        '.js': 'application/javascript',
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.gif': 'image/gif',
    };
    return mimeTypes[extension] || 'application/octet-stream';
}

// Main Lambda@Edge handler
exports.handler = async (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;
    const uri = request.uri;
    const extension = path.extname(uri);
    const staticAssetExtensions = ['.css', '.js', '.png', '.jpg', '.jpeg', '.gif'];

    const cookies = headers.cookie ? headers.cookie[0].value : "";
    const isAuthenticated = cookies.includes(`${AUTH_COOKIE_NAME}=${AUTH_COOKIE_VALUE}`);

    // Serve static assets directly
    if (staticAssetExtensions.includes(extension)) {
        // Allow static files to pass through without authentication
        return callback(null, request);
    }

    // Handle login page
    if (uri === LOGIN_PAGE) {
        // If the user is submitting the login form, check the password
        if (request.querystring.includes("password=")) {
            const submittedPassword = decodeURIComponent(request.querystring.split("password=")[1]);
            if (submittedPassword === PASSWORD) {
                // User authenticated, set a cookie and redirect to the index page
                const response = generateResponse(
                    302,
                    "Found",
                    {
                        location: [{ key: "Location", value: INDEX_PAGE }],
                        "set-cookie": [{
                            key: "Set-Cookie",
                            value: `${AUTH_COOKIE_NAME}=${AUTH_COOKIE_VALUE}; Path=/; HttpOnly`,
                        }],
                    },
                    ""
                );
                return callback(null, response);
            } else {
                // Incorrect password, reload the login page with an alert
                const response = generateResponse(
                    200,
                    "OK",
                    { "content-type": [{ key: "Content-Type", value: "text/html" }] },
                    `<!DOCTYPE html>
                     <html>
                     <body>
                     <script>alert("Incorrect password, please try again.");</script>
                     <script>window.location.href='${LOGIN_PAGE}';</script>
                     </body>
                     </html>`
                );
                return callback(null, response);
            }
        }

        // Render login page
        return callback(null, request);
    }

    // Redirect unauthenticated users to the login page
    if (!isAuthenticated) {
        const response = generateResponse(
            302,
            "Found",
            { location: [{ key: "Location", value: LOGIN_PAGE }] },
            ""
        );
        return callback(null, response);
    }

    // Allow authenticated users to access the requested page
    return callback(null, request);
};
