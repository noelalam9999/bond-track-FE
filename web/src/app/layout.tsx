import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({ variable: "--font-geist-sans", subsets: ["latin"] });
const geistMono = Geist_Mono({ variable: "--font-geist-mono", subsets: ["latin"] });

export const metadata: Metadata = {
  title: "BondTrack — Fund tracking for modern fund managers",
  description:
    "BondTrack gives fund managers one live view of positions, cash flows, investor capital and performance — without another night of spreadsheet reconciliation.",
  openGraph: {
    title: "BondTrack — Fund tracking for modern fund managers",
    description:
      "One live view of positions, cash flows, investor capital and performance across every fund you run.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body className={`${geistSans.variable} ${geistMono.variable}`}>{children}</body>
    </html>
  );
}
