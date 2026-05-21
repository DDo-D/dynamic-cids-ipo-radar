export const config = {
  runtime: "edge"
};

export default async function handler(request) {
  if (request.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const expected = process.env.SITE_PASSWORD || "";
  if (!expected) {
    return Response.json({ ok: true, disabled: true });
  }

  let body = {};
  try {
    body = await request.json();
  } catch {
    return Response.json({ ok: false, error: "invalid_json" }, { status: 400 });
  }

  const password = String(body.password || "");
  if (password !== expected) {
    return Response.json({ ok: false, error: "wrong_password" }, { status: 401 });
  }

  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      "Set-Cookie": "ipo-radar-auth=1; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=604800"
    }
  });
}
