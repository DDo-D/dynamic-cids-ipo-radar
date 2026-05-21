import { useEffect, useState } from "react";

const UNLOCK_KEY = "ipoRadarSiteUnlocked";

export function markSiteUnlocked() {
  try {
    sessionStorage.setItem(UNLOCK_KEY, "1");
  } catch {
    /* ignore */
  }
}

export default function SiteGate({ children }) {
  const [unlocked, setUnlocked] = useState(false);
  const [checking, setChecking] = useState(true);
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const response = await fetch("/api/auth/check", { credentials: "include" });
        if (!cancelled && response.ok) {
          markSiteUnlocked();
          setUnlocked(true);
        }
      } catch {
        /* show login */
      } finally {
        if (!cancelled) setChecking(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  async function handleSubmit(event) {
    event.preventDefault();
    setError("");
    setLoading(true);
    try {
      const response = await fetch("/api/auth/unlock", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ password }),
        credentials: "include"
      });
      if (!response.ok) {
        setError("비밀번호가 올바르지 않습니다.");
        return;
      }
      markSiteUnlocked();
      setUnlocked(true);
      if (window.location.pathname === "/login") {
        window.location.replace("/");
      }
    } catch {
      setError("인증 요청에 실패했습니다. 잠시 후 다시 시도해주세요.");
    } finally {
      setLoading(false);
    }
  }

  if (checking) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-paper text-steel">
        <div className="rounded-md bg-white/90 px-4 py-3 text-sm shadow-panel">확인 중…</div>
      </div>
    );
  }

  if (unlocked) {
    return children;
  }

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top,#fcfaf2_0%,#f6f3e8_55%,#efe8d8_100%)] px-4 py-8">
      <div className="mx-auto flex min-h-[calc(100vh-4rem)] max-w-md items-center justify-center">
        <form
          onSubmit={handleSubmit}
          className="w-full rounded-2xl bg-white/90 p-6 shadow-panel md:p-8"
        >
          <h1 className="text-xl font-black tracking-tight text-ink md:text-2xl">
            Dynamic CIDS IPO Radar
          </h1>
          <p className="mt-1 text-xs text-steel md:text-sm">접속 비밀번호를 입력하세요.</p>

          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="mt-6 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-ink outline-none focus:border-forest focus:ring-1 focus:ring-forest"
            placeholder="비밀번호"
            autoFocus
            required
          />

          {error ? (
            <div className="mt-3 rounded-md bg-rose-100 p-3 text-sm text-rose-700">{error}</div>
          ) : null}

          <button
            type="submit"
            disabled={loading}
            className="mt-6 w-full rounded-md bg-ink px-4 py-2 text-sm font-semibold text-white hover:bg-ink/90 disabled:cursor-not-allowed disabled:bg-slate-500"
          >
            {loading ? "확인 중…" : "입장"}
          </button>
        </form>
      </div>
    </div>
  );
}
