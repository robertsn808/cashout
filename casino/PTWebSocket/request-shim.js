// Minimal request() shim using global fetch (Node 18+)
// Supports the subset used in this project.

module.exports = function request(options, callback) {
  try {
    const url = options.url || options.uri || options.href;
    const method = (options.method || 'GET').toUpperCase();
    const headers = Object.assign({}, options.headers || {});

    let body = options.body;
    if (options.json) {
      headers['Content-Type'] = headers['Content-Type'] || 'application/json';
      if (body != null && typeof body !== 'string') {
        body = JSON.stringify(body);
      }
    }

    fetch(url, { method, headers, body })
      .then(res => res.text().then(text => ({ res, text })))
      .then(({ res, text }) => callback(null, res, text))
      .catch(err => callback(err));
  } catch (err) {
    callback(err);
  }
};

