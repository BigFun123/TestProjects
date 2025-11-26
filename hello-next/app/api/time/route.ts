export async function GET() {
  const now = new Date().toISOString();

  return new Response(
    JSON.stringify({ time: now }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
}