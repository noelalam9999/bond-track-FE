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

## CI/CD → TestFlight (test on your own iPhone)

Every push to `main` builds the app and uploads it to TestFlight via
GitHub Actions (`.github/workflows/testflight.yml` + `fastlane/`), using a
macOS runner — no personal Mac required.

### One-time Apple-side setup
1. Enroll in the **Apple Developer Program** ($99/yr) at developer.apple.com if you haven't.
2. In **App Store Connect**, create the app record with bundle ID `com.noel.BondTrack`.
3. In **App Store Connect → Users and Access → Integrations**, create an
   **App Store Connect API key** (download the `.p8` once — Apple won't show it again).
4. In **developer.apple.com → Certificates**, create an **Apple Distribution**
   certificate. You don't need a Mac for this — you can generate the CSR with OpenSSL
   on any machine:
   ```bash
   openssl genrsa -out ios_distribution.key 2048
   openssl req -new -key ios_distribution.key -out CSR.certSigningRequest \
     -subj "/emailAddress=you@example.com, CN=Your Name, C=BD"
   ```
   Upload `CSR.certSigningRequest` on the portal, download the resulting `.cer`, then:
   ```bash
   openssl x509 -in ios_distribution.cer -inform DER -out ios_distribution.pem
   openssl pkcs12 -export -out ios_distribution.p12 \
     -inkey ios_distribution.key -in ios_distribution.pem -passout pass:CHOOSE_A_PASSWORD
   base64 -w0 ios_distribution.p12   # (macOS: base64 -i ios_distribution.p12 | pbcopy)
   ```
5. In **developer.apple.com → Profiles**, create an **App Store** provisioning
   profile for `com.noel.BondTrack` using that certificate. Download the
   `.mobileprovision` and base64-encode it the same way.

### GitHub repository secrets
Add these under **Settings → Secrets and variables → Actions** on this repo
(never share these in chat with anyone, including an AI assistant):

| Secret | Value |
|---|---|
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_ISSUER_ID` | App Store Connect issuer ID |
| `ASC_KEY_CONTENT_BASE64` | base64 of the `.p8` API key file |
| `APPLE_TEAM_ID` | Your 10-character Apple Developer Team ID |
| `PROVISIONING_PROFILE_NAME` | Exact name of the App Store provisioning profile |
| `BUILD_CERTIFICATE_BASE64` | base64 of `ios_distribution.p12` |
| `P12_PASSWORD` | Password you chose when exporting the `.p12` |
| `BUILD_PROVISION_PROFILE_BASE64` | base64 of the `.mobileprovision` |
| `KEYCHAIN_PASSWORD` | Any password — used only for the CI's temporary keychain |

### Running it
- Push to `main`, or trigger manually from the **Actions** tab → *TestFlight* → **Run workflow**.
- After it succeeds, the build appears in **App Store Connect → TestFlight**
  (processing takes a few minutes).
- Add yourself as an **internal tester** (App Store Connect → your app → TestFlight →
  Internal Testing → add your Apple ID) — internal testers don't need Beta App Review.
- Install **TestFlight** from the App Store on your iPhone, accept the invite email,
  and install BondTrack.
