/**
 * Servidor estático simples (só Node, sem npm).
 * Uso: node servir-celular.js
 */
const http = require("http");
const fs = require("fs");
const path = require("path");
const os = require("os");

const ROOT = __dirname;
const PORT = Number(process.env.PORT || 3333);

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png",
  ".gif": "image/gif",
  ".ico": "image/x-icon",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml; charset=utf-8",
  ".txt": "text/plain; charset=utf-8",
  ".xml": "application/xml; charset=utf-8",
  ".webp": "image/webp",
  ".url": "text/plain; charset=utf-8",
};

function localIPv4s() {
  const out = [];
  const nets = os.networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name] || []) {
      if (net.family === "IPv4" && !net.internal) out.push(net.address);
    }
  }
  return out;
}

const server = http.createServer((req, res) => {
  let urlPath = decodeURIComponent((req.url || "/").split("?")[0]);
  if (urlPath === "/") urlPath = "/index.html";

  const rel = path.normalize(urlPath).replace(/^(\.\.(\/|\\|$))+/, "");
  const filePath = path.join(ROOT, rel);

  if (!filePath.startsWith(ROOT)) {
    res.writeHead(403);
    return res.end("Forbidden");
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(err.code === "ENOENT" ? 404 : 500);
      return res.end(err.code === "ENOENT" ? "Não encontrado" : "Erro no servidor");
    }
    const ext = path.extname(filePath).toLowerCase();
    res.setHeader("Content-Type", MIME[ext] || "application/octet-stream");
    res.end(data);
  });
});

server.listen(PORT, "0.0.0.0", () => {
  console.log("");
  console.log("Pasta:", ROOT);
  console.log("Porta:", PORT);
  console.log("");
  console.log("No PC:  http://127.0.0.1:" + PORT + "/");
  const ips = localIPv4s();
  if (ips.length) {
    console.log("No celular (MESMO Wi-Fi do PC):");
    ips.forEach((ip) => console.log("        http://" + ip + ":" + PORT + "/"));
  } else {
    console.log("(Não achei IP da rede local — use o link do cloudflared.)");
  }
  console.log("");
  console.log("Mantenha esta janela aberta. Ctrl+C para parar.");
  console.log("");
});
