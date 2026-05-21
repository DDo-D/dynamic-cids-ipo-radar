export const config = {
  runtime: "edge"
};

export default function handler(request) {
  const expected = process.env.SITE_PASSWORD || "";
  if (!expected) {
    return Response.json({ ok: true, disabled: true });
  }

  const cookie = request.cookies.get("ipo-radar-auth");
  if (cookie?.value === "1") {
    return Response.json({ ok: true });
  }

  return Response.json({ ok: false }, { status: 401 });
}
