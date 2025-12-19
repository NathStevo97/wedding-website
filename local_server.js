'use strict';

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');
const querystring = require('querystring');
const config = require('./config.json');

const PORT = 3000;
const PASSWORD = config.auth_password;
const LOGIN_PAGE = '/login.html';
const INDEX_PAGE = '/index.html';
const AUTH_COOKIE_NAME = 'auth';
const AUTH_COOKIE_VALUE = 'valid';
const BASE_DIR = path.join(__dirname, 'site');

// Helper function to determine MIME type
function getMimeType(extension) {
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
    return mimeTypes[extension] || 'application/octet-stream';
}

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

// Helper function to inject JavaScript into login page
function injectLoginScript(html) {
    return html.replace('</body>', `
    <script>
        document.querySelector('form').onsubmit = function(event) {
            event.preventDefault();
            const password = document.getElementById('password').value;
            window.location.href = '/login?password=' + encodeURIComponent(password);
        };
    </script>
    </body>
    `);
}

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const pathname = parsedUrl.pathname;
    const cookies = parseCookies(req);
    const isAuthenticated = cookies[AUTH_COOKIE_NAME] === AUTH_COOKIE_VALUE;

    // Handle static assets
    const fullPath = path.join(BASE_DIR, pathname);
    const ext = path.extname(fullPath);
    if (fs.existsSync(fullPath) && fs.statSync(fullPath).isFile() && pathname !== '/login.html' && pathname !== '/index.html') {
        const mimeType = getMimeType(ext);
        res.writeHead(200, { 'Content-Type': mimeType });
        fs.createReadStream(fullPath).pipe(res);
        return;
    }

    // Handle login page
    if (pathname === LOGIN_PAGE || pathname === '/login') {
        // Check for password in query string
        if (parsedUrl.query.password) {
            const submittedPassword = parsedUrl.query.password;

            if (submittedPassword === PASSWORD) {
                // Set auth cookie and redirect to index
                res.writeHead(302, {
                    'Set-Cookie': `${AUTH_COOKIE_NAME}=${AUTH_COOKIE_VALUE}; Path=/; HttpOnly`,
                    'Location': INDEX_PAGE
                });
                res.end();
                return;
            } else {
                // Show error and redirect back to login
                res.writeHead(200, { 'Content-Type': 'text/html' });
                res.end(`
                    <!DOCTYPE html>
                    <html>
                    <body>
                        <script>
                            alert('Incorrect password. Please try again.');
                            window.location.href='${LOGIN_PAGE}';
                        </script>
                    </body>
                    </html>
                `);
                return;
            }
        }

        // Serve login page with injected script
        const loginPath = path.join(BASE_DIR, 'login.html');
        if (fs.existsSync(loginPath)) {
            let loginContent = fs.readFileSync(loginPath, 'utf8');
            loginContent = injectLoginScript(loginContent);
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(loginContent);
        } else {
            res.writeHead(404, { 'Content-Type': 'text/plain' });
            res.end('Login page not found');
        }
        return;
    }

    // Redirect unauthenticated users to login
    if (!isAuthenticated && pathname !== LOGIN_PAGE) {
        res.writeHead(302, { 'Location': LOGIN_PAGE });
        res.end();
        return;
    }

    // Serve index page for authenticated users
    if (pathname === '/' || pathname === INDEX_PAGE) {
        const indexPath = path.join(BASE_DIR, 'index.html');
        if (fs.existsSync(indexPath)) {
            res.writeHead(200, { 'Content-Type': 'text/html' });
            fs.createReadStream(indexPath).pipe(res);
        } else {
            res.writeHead(404, { 'Content-Type': 'text/plain' });
            res.end('Index page not found');
        }
        return;
    }

    // 404 for anything else
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('404 Not Found');
});

server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
});
