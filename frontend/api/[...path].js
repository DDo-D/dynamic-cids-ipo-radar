const BACKEND =
  process.env.BACKEND_URL ||
  process.env.VITE_API_BASE_URL ||
  "https://ipo-radar-backend.vercel.app";

export const config = {
  runtime: "edge"
};

export default async function handler(request) {
  const url = new URL(request.url);
  const base = BACKEND.replace(/\/$/, "");
  const target = `${base}${url.pathname}${url.search}`;

  const headers = new Headers(request.headers);
  headers.delete("host");

  return fetch(target, {
    method: request.method,
    headers,
    body: request.method === "GET" || request.method === "HEAD" ? undefined : request.body
  });
}
