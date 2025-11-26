"use client";

import { useEffect, useState } from "react";

export default function Home() {
  const [time, setTime] = useState("");

  useEffect(() => {
    async function load() {
      const res = await fetch("/api/time");
      const data = await res.json();
      setTime(data.time);
    }
    load();
  }, []);

  return (
    <main>
      <strong>{time}</strong>
    </main>
  );
}
