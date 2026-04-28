# Deep Faced

Deep Faced is a Next.js and Material UI prototype for creating, uploading, downloading, and trying
on community-made character faces. It is designed for Vercel hosting with Supabase providing
Postgres metadata, auth, and Storage for DeepAR effect packages.

## Apps

- `apps/web`: Next.js App Router site with the landing page, community faces marketplace, Face
  Booth, upload intake, tutorials, download page, and face creator.
- `apps/desktop`: desktop companion architecture plus a SwiftUI macOS app scaffold for OS-level
  virtual camera output.

## Packages

- `packages/shared`: shared TypeScript domain types.
- `packages/effects`: starter/community face metadata and local fixtures.
- `packages/ar-engine`: DeepAR-first adapter boundary with a canvas prototype renderer.
- `supabase/schema.sql`: reference schema for the Vercel Supabase project.

## Commands

```bash
npm run dev
npm run build
npm run lint
npm run typecheck
npm run mac:build -w apps/desktop
```

## Notes

The current AR renderer is a functional canvas prototype behind the DeepAR adapter boundary. Replace
it with the real DeepAR SDK integration once a license key and packaged `.deepar` effects are
available.
