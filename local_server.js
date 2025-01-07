'use strict';

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');
const querystring = require('querystring');
const config = require('./config.json'); // Load password from config file

const PORT = 3000;
const PASSWORD = config.auth_password; // Password from config.json

// Set BASE_DIR to the directory where login.html, index.html, and other assets are located
const BASE_DIR = path.join(__dirname, 'site'); // Adjust 'public' to the directory name if different

// Load login and index files once on server start
let loginPage = fs.readFileSync(path.join(BASE_DIR, 'login.html'), 'utf8');
const indexPage = fs.readFileSync(path.join(BASE_DIR, 'index.html'), 'utf8');

// Inject JavaScript into login page for handling onsubmit event
loginPage = loginPage.replace('</body>', `
<script>
    function login(event) {
        event.preventDefault();
        const password = document.getElementById('password').value;

        fetch('/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'password=' + encodeURIComponent(password)
        })
        .then(response => {
            if (response.redirected) {
                window.location.href = response.url;
            } else {
                alert('Incorrect password. Please try again.');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An error occurred. Please try again.');
        });
    }
</script>
</body>
`);

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url);
    const pathname = path.join(BASE_DIR, parsedUrl.pathname);
    const ext = path.extname(pathname);
    const cookies = parseCookies(req);

    // Define MIME types for common static assets
    const mimeTypes = {
        '.html': 'text/html',
        '.css': 'text/css',
        '.js': 'application/javascript',
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.gif': 'image/gif',
        '.svg': 'image/svg+xml',
        '.ico': 'image/x-icon'
    };

    // Check if user is authenticated by verifying the 'auth' cookie
    const isAuthenticated = cookies.auth === 'valid';

    // Handle login POST request
    if (parsedUrl.pathname === '/login' && req.method === 'POST') {
        let body = '';

        // Collect the POST data
        req.on('data', chunk => {
            body += chunk.toString();
        });

        req.on('end', () => {
            const parsedBody = querystring.parse(body);
            const submittedPassword = parsedBody.password;

            if (submittedPassword === PASSWORD) {
                // Set 'auth=valid' cookie and redirect to home page if password is correct
                res.writeHead(302, {
                    'Set-Cookie': 'auth=valid; Path=/; HttpOnly',
                    'Location': '/'
                });
                res.end();
            } else {
                // Respond with a 401 status for incorrect password
                res.writeHead(401, { 'Content-Type': 'text/plain' });
                res.end('Unauthorized');
            }
        });
    } else if (parsedUrl.pathname === '/login') {
        // Serve login page for GET request
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(loginPage);
    } else {
        // Redirect to login page if user is not authenticated
        if (!isAuthenticated) {
            res.writeHead(302, { 'Location': '/login' });
            res.end();
            return;
        }

        // Serve static files (e.g., CSS, JavaScript, images)
        if (fs.existsSync(pathname) && fs.statSync(pathname).isFile()) {
            const mimeType = mimeTypes[ext] || 'application/octet-stream';
            res.writeHead(200, { 'Content-Type': mimeType });
            fs.createReadStream(pathname).pipe(res);
        } else {
            // Serve the protected content (index.html) if no specific file is requested
            if (parsedUrl.pathname === '/') {
                res.writeHead(200, { 'Content-Type': 'text/html' });
                res.end(indexPage);
            } else {
                // Respond with a 404 if the file is not found
                res.writeHead(404, { 'Content-Type': 'text/plain' });
                res.end('404 Not Found');
            }
        }
    }
});

// Helper function to parse cookies from request headers
function parseCookies(request) {
    const list = {};
    const cookieHeader = request.headers.cookie;

    if (cookieHeader) {
        cookieHeader.split(';').forEach(cookie => {
            const parts = cookie.split('=');
            list[parts.shift().trim()] = decodeURI(parts.join('='));
        });
    }

    return list;
}

// Start the server
server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
});