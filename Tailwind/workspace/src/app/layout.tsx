import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Tailwind Theme Demo",
  description: "Demonstrating custom themes in Tailwind CSS",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
