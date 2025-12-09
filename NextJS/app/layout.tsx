import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Next.js Recharts Demo",
  description: "A Next.js app with React 18 and Recharts",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body style={{ margin: 0, fontFamily: 'system-ui, -apple-system, sans-serif' }}>
        {children}
      </body>
    </html>
  );
}
