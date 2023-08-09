import {google} from 'googleapis';
import http from 'http';
import https from 'https';
import url from 'url';


/**
 * To use OAuth2 authentication, we need access to a CLIENT_ID, CLIENT_SECRET, AND REDIRECT_URI.
 * To get these credentials for your application, visit
 * https://console.cloud.google.com/apis/credentials.
 */
const oauth2Client = new google.auth.OAuth2(
  process.env.CLIENT_ID,
  process.env.CLIENT_SECRET,
  `https://${process.env.PROJECT_ID}.ew.r.appspot.com/oauth2callback`,
);

// Access scopes for read-only Drive activity.
const scopes = [
  'https://www.googleapis.com/auth/userinfo.profile'
];

// Generate a url that asks permissions user profile scope
const authorizationUrl = oauth2Client.generateAuthUrl({
  // 'online' (default) or 'offline' (gets refresh_token)
  access_type: 'offline',
  scope: scopes,
  // Enable incremental authorization. Recommended as a best practice.
  include_granted_scopes: true
});

let userCredential = null;


async function main() {
  const server = http.createServer(async function (req, res) {
    // Example on redirecting user to Google's OAuth 2.0 server.
    if (req.url == '/') {
        res.writeHead(301, { "Location": authorizationUrl });
    }

    // Receive the callback from Google's OAuth 2.0 server.
    if (req.url.startsWith('/oauth2callback')) {
      // Handle the OAuth 2.0 server response
      let q = url.parse(req.url, true).query;

      if (q.error) { // An error response e.g. error=access_denied
        console.log('Error:' + q.error);
      } else { // Get access and refresh tokens (if access_type is offline)
        let { tokens } = await oauth2Client.getToken(q.code);
        oauth2Client.setCredentials(tokens);

        userCredential = tokens;

        console.log(userCredential);
      }
    }

    // Example on revoking a token
    if (req.url == '/revoke') {
      // Build the string for the POST request
      let postData = "token=" + userCredential.access_token;

      // Options for POST request to Google's OAuth 2.0 server to revoke a token
      let postOptions = {
        host: 'oauth2.googleapis.com',
        port: '443',
        path: '/revoke',
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Length': Buffer.byteLength(postData)
        }
      };

      // Set up the request
      const postReq = https.request(postOptions, function (res) {
        res.setEncoding('utf8');
        res.on('data', d => {
          console.log('Response: ' + d);
        });
      });

      postReq.on('error', error => {
        console.log(error)
      });

      // Post the request with data
      postReq.write(postData);
      postReq.end();
    }
    res.end();
  }).listen(8080);
}
main().catch(console.error);