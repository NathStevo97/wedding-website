'use strict';
const fs = require('fs');
const path = require('path');

// Load the configuration file at the start of the Lambda function
const configPath = path.resolve(__dirname, 'config.json');
let config;

try {
    config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
} catch (error) {
    console.error('Error reading config file:', error);
}

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;
    const uri = request.uri;

    // Get the password from the configuration file
    const password = config.site_password;
    const loginPage = '/login.html';

    // Check if the user is already authenticated by verifying the 'auth' cookie
    const cookies = headers.cookie ? headers.cookie[0].value : '';
    const isAuthenticated = cookies.includes('auth=valid');

    // If this is a request to the login page or the user is authenticated, continue
    if (uri === loginPage || isAuthenticated) {
        callback(null, request);
        return;
    }

    // Handle login form submission (POST request to /login)
    if (request.method === 'POST' && uri === '/login') {
        // Parse the form data (password) from the POST body
        const body = Buffer.from(request.body.data, 'base64').toString();
        const submittedPassword = new URLSearchParams(body).get('password');

        // Check if the submitted password is correct
        if (submittedPassword === password) {
            // Set 'auth=valid' cookie and redirect to the original requested URI
            const response = {
                status: '302',
                statusDescription: 'Found',
                headers: {
                    'location': [{ key: 'Location', value: '/' }],
                    'set-cookie': [{ key: 'Set-Cookie', value: 'auth=valid; Path=/; Secure; HttpOnly' }]
                }
            };
            callback(null, response);
        } else {
            // Redirect back to the login page if the password is incorrect
            const response = {
                status: '302',
                statusDescription: 'Found',
                headers: {
                    'location': [{ key: 'Location', value: loginPage }]
                }
            };
            callback(null, response);
        }

        return;
    }

    // If the user is not authenticated, redirect to the login page
    const response = {
        status: '302',
        statusDescription: 'Found',
        headers: {
            'location': [{ key: 'Location', value: loginPage }]
        }
    };

    callback(null, response);
};
