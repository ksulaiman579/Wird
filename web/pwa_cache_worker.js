// Wird's own offline cache — Flutter's auto-generated
// flutter_service_worker.js in this Flutter version is a deprecated stub
// that just self-unregisters (it no longer precaches anything), so the
// app registers this file itself (see index.html) for the plan's "PWA
// works fully offline after first load" requirement.
//
// Two layers:
//  1. Precache the app shell on install — the files needed just to boot
//     Flutter and get a frame on screen (index.html, main.dart.js, the
//     canvaskit renderer, and drift's web assets). Static filenames
//     (Flutter's default web build doesn't content-hash them), so this
//     list only needs updating if the build output's shape changes.
//  2. Cache-first-then-network for everything else (bundled Quran/Hadith/
//     dua JSON, fonts, icons) — opportunistically caught as the user
//     browses, no manifest to keep in sync with each build.
// RULE: bump this version on EVERY release that changes icons, splash
// images, theme colors, or any other cached asset — the cache-first layer
// below happily serves stale files forever otherwise (that's exactly how
// the old M17-era icon survived the M19 logo swap on returning clients).
// v5: M21 — logo re-cut + Royal Emerald restyle.
// v6: M22.8 palette+layout.
const CACHE_NAME = 'wird-offline-v7'; // M23 overhaul: responsive shell, hadith grades, zakah, motion

const APP_SHELL = [
  './',
  'index.html',
  'main.dart.js',
  'flutter.js',
  'flutter_bootstrap.js',
  'manifest.json',
  'favicon.png',
  'sqlite3.wasm',
  'drift_worker.js',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'canvaskit/chromium/canvaskit.js',
  'canvaskit/chromium/canvaskit.wasm',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL)),
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key)),
      ),
    ),
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  // Only cache same-origin GETs — everything this app needs is same-origin
  // (bundled assets, app shell); cross-origin requests (if any) pass
  // through untouched.
  if (request.method !== 'GET' || new URL(request.url).origin !== self.location.origin) {
    return;
  }

  event.respondWith(
    caches.open(CACHE_NAME).then(async (cache) => {
      const cached = await cache.match(request);
      if (cached) return cached;

      try {
        const response = await fetch(request);
        if (response.ok) {
          cache.put(request, response.clone());
        }
        return response;
      } catch (err) {
        // Offline and not yet cached — nothing more we can do for this
        // request.
        throw err;
      }
    }),
  );
});
