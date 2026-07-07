# BondTrack — Bangladesh Government Treasury Bond Tracker (iOS)

SwiftUI implementation of the BondTrack Figma design:
https://www.figma.com/design/kgXQcRepAmCDYvWEDR9X8k

Track, trade & reinvest Bangladesh Government Treasury Bonds (BGTBs) across
three user roles — **Investor**, **Fund Manager**, and **Super Admin**.

## Features

### Investor
- Portfolio dashboard: total value, weighted yield, live BGTB yield strip (Bangladesh Bank feed)
- First-run experience: setup checklist, empty state, guided "Add your first bond"
- Add a bond: searchable ISIN picker backed by a cached BB bond master;
  coupon rate, market yield & maturity auto-filled and locked;
  opening equity (settlement paid, incl. premium + accrued interest);
  TDS default 10% (editable) applied to every coupon;
  full disbursement schedule (gross / TDS / net) generated at creation time
- Bond detail: maturity progress, coupon calendar, live YTM vs your coupon
- Secondary market: browse verified fund-manager listings (with ISIN), filters & sort
- Contact a fund manager about a listing
- Reallocation request: broadcast maturing holdings to all verified FMs

### Fund Manager
- Institutional onboarding (BSEC licence, docs) → pending Super Admin approval
- Desk dashboard: listings, inquiries, reallocation-request KPIs
- Create a listing (ask price, implied YTM vs BB benchmark)
- Requests inbox: investor reallocation requests → propose allocation

### Super Admin
- Platform overview, FM approvals (approve / reject), listing screening
- Bangladesh Bank API health (uptime, latency, last sync)
- Users & roles management

## Architecture
- **SwiftUI + MVVM-lite** — a single `AppState` observable object per session
- `BangladeshBankService` — protocol with a mock implementation;
  swap `MockBangladeshBankService` for a real client hitting the BB endpoints
- `CouponCalculator` — pure function generating the disbursement schedule
  (semi-annual coupons, TDS applied per payment)
- No third-party dependencies

## Getting started
Requires Xcode 15+ / iOS 17+.

Option A — XcodeGen (recommended):
```bash
brew install xcodegen
xcodegen generate
open BondTrack.xcodeproj
```

Option B — manual: create a new iOS App project named `BondTrack`
in Xcode and drag the `BondTrack/` source folder in.

## Roadmap
- Real Bangladesh Bank yield/bond-master client + background refresh
- Push notifications for coupon payouts (3-day reminder)
- FM ↔ investor chat threads
- Prototype-linked onboarding OTP flow
