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
// STRATEGY (v8): the app CODE + shell (index.html, main.dart.js,
// flutter_bootstrap.js, flutter.js and any navigation) is now **network-first**
// — always fetch the latest when online, fall back to cache only when offline.
// This fixes the "installed/home-screen PWA never sees updates" bug: previously
// EVERYTHING was cache-first, so a returning client served a stale main.dart.js
// forever unless CACHE_NAME was manually bumped (easy to forget — and it was
// forgotten for 1.2.1). Immutable DATA/assets (Quran/Hadith/dua JSON, fonts,
// wasm, canvaskit, icons) stay cache-first for instant offline use.
//
// Bumping CACHE_NAME is now only needed when a CACHED DATA asset or icon must be
// force-refreshed; code updates propagate on their own.
// v5: M21 logo re-cut. v6: M22.8 palette. v7: M23 overhaul.
const CACHE_NAME = 'wird-offline-v8'; // v8: network-first app shell (PWA update fix)

// Requests that must always prefer the network so updates reach returning
// clients: the HTML document and the Flutter bootstrap/code entrypoints.
const NETWORK_FIRST = [
  'index.html',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
];

function isNetworkFirst(request) {
  if (request.mode === 'navigate') return true;
  const path = new URL(request.url).pathname;
  if (path === '/' || path.endsWith('/')) return true;
  return NETWORK_FIRST.some((name) => path.endsWith(name));
}

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
      // Code + navigation: network-first so returning (installed) clients
      // always pick up a new deploy, with the cache as an offline fallback.
      if (isNetworkFirst(request)) {
        try {
          const response = await fetch(request);
          if (response && response.ok) cache.put(request, response.clone());
          return response;
        } catch (err) {
          const cached =
              (await cache.match(request)) ??
              (request.mode === 'navigate'
                  ? (await cache.match('index.html')) ?? (await cache.match('./'))
                  : undefined);
          if (cached) return cached;
          throw err;
        }
      }

      // Everything else (immutable data/assets): cache-first for instant
      // offline use, populated opportunistically as the user browses.
      const cached = await cache.match(request);
      if (cached) return cached;
      try {
        const response = await fetch(request);
        if (response.ok) cache.put(request, response.clone());
        return response;
      } catch (err) {
        throw err;
      }
    }),
  );
});
