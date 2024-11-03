import config from './config.js';

// Import libraries
import express from 'express';
import datadog from 'connect-datadog';

// Create app
const app = express();

// Set app to use the datadog middleware
const connectDatadog = datadog(config.datadog);
app.use(connectDatadog);

// Routes
app.get('/', (req, res) => res.send('Hello World!'));
app.get('/test', wrapped(getTestValue));

// Start app
app.listen(3000, () => console.log('Example app listening on port 3000!'));

// --- Request handlers ---

function wrapped(handler) {
  return async (req, res) => {
    try {
      const response = await handler();
      res.status(200).set({"Cache-Control":"no-cache, no-store, must-revalidate"}).send(response);
    } catch (error) {
      res.status(500).send(error);
    }
  }
}

async function getTestValue() {
  return "This is a test";
}

// --- helper functions ---

function debug(...args) {
  if (!config.debug) {
    return;
  }

  console.log(...args);
}
