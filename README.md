# VisionTraders.com starter

Mobile-friendly public landing page and Supabase authentication starter for VisionTraders.

## Included
- Responsive green/blue/white landing page
- Sign-up and sign-in UI using Supabase Auth
- SQL starter schema for profiles, deposit requests, withdrawal requests, ledger entries, tasks and referrals
- Row Level Security policies for basic user-owned records

## Important setup steps
1. Create a Supabase project.
2. In Supabase SQL Editor, review and run `supabase-schema.sql`.
3. In Supabase Authentication settings, enable email confirmations and configure the site URL plus redirect URLs.
4. Open `app.js` and replace the two placeholders with your Supabase Project URL and publishable/anon key. Never use a service-role key in browser code.
5. In GitHub, open this repository, choose **Add file → Upload files**, upload all files from this folder, and commit.
6. In the repository, open **Settings → Pages**, select **Deploy from a branch**, choose `main` and `/ (root)`, then save.
7. Wait for GitHub Pages to publish, then open the published URL and test signup.

## Not yet production-ready
The current starter is not a complete financial platform. It does not implement a live balance screen, payment-proof storage, admin review interface, crypto transaction verification, payout processing, or verified-profit distribution. Those features require secure server-side authorization, private storage, audit logs, transaction reconciliation, and legal/compliance review. Do not accept real deposits until those controls have been implemented and independently tested.

No investment return is guaranteed. Any profit distributions must reflect genuine, verified profits and applicable law.
