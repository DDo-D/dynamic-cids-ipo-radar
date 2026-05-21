import { initDb } from "../src/db.js";
import { createApp } from "../src/app.js";

let app = null;
let readyPromise = null;

function getApp() {
  if (!app) {
    app = createApp();
  }
  return app;
}

async function ensureReady() {
  if (!readyPromise) {
    readyPromise = initDb();
  }
  await readyPromise;
}

export default async function handler(req, res) {
  try {
    await ensureReady();
    return getApp()(req, res);
  } catch (error) {
    const isProd = String(process.env.NODE_ENV || "").toLowerCase() === "production";
    if (isProd) {
      return res.status(500).json({ error: "Internal server error" });
    }
    return res.status(500).json({ error: String(error.message || error) });
  }
}
