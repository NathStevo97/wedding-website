'use strict';

// Replace with your desired password
const PASSWORD = "securepassword";
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

// Main Lambda@Edge handler
exports.handler = async (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;

    const cookies = headers.cookie ? headers.cookie[0].value : "";
    const isAuthenticated = cookies.includes(`${AUTH_COOKIE_NAME}=${AUTH_COOKIE_VALUE}`);

    if (request.uri === LOGIN_PAGE) {
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
                            value: `${AUTH_COOKIE_NAME}=${AUTH_COOKIE_VALUE}; Path=/; HttpOnly`
                        }],
                    },
                    ""
                );
                return callback(null, response);
            } else {
                // Incorrect password, stay on the login page
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

    if (!isAuthenticated) {
        // Redirect unauthenticated users to the login page
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
