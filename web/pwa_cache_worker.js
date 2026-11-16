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
const CACHE_NAME = 'wird-offline-v11'; // v11: fonts + Quran text cached after activation (audit WQA-032)

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

// Fetched in the background after install so the app still starts
// offline in every language and opens any surah without a prior visit.
// Before v10 these were only cached if the page happened to request them
// through the worker, which left the script fonts out (audit WQA-032).
const OFFLINE_DATA = [
  'assets/FontManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/assets/fonts/UthmanicHafs.otf',
  'assets/assets/fonts/Marcellus-Regular.ttf',
  'assets/assets/fonts/NotoNastaliqUrdu.ttf',
  'assets/assets/fonts/NotoSansBengali.ttf',
  'assets/assets/fonts/NotoSansDevanagari.ttf',
  'assets/assets/fonts/NotoSansMalayalam.ttf',
  'assets/assets/data/quran/meta.json',
  ...Array.from({ length: 114 }, (_, i) =>
      `assets/assets/data/quran/surah_${String(i + 1).padStart(3, '0')}.json`),
];

self.addEventListener('install', (event) => {
  // Only the small app shell blocks install. Fetching the fonts and 115
  // Quran files here kept the worker stuck "installing" (no offline at all)
  // on a slow link; they are fetched after activation instead.
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL)),
  );
  self.skipWaiting();
});

let offlineDataJob = null;

// Fills OFFLINE_DATA in the background: 6 at a time, 15 s per file,
// skipping what is already cached. Safe to call repeatedly; a failed file
// is retried on a later visit.
function cacheOfflineData() {
  if (offlineDataJob) return offlineDataJob;
  offlineDataJob = (async () => {
    const cache = await caches.open(CACHE_NAME);
    const queue = [...OFFLINE_DATA];
    const worker = async () => {
      while (queue.length) {
        const url = queue.shift();
        try {
          if (await cache.match(url)) continue;
          const ctrl = new AbortController();
          const timer = setTimeout(() => ctrl.abort(), 15000);
          const res = await fetch(url, { signal: ctrl.signal });
          clearTimeout(timer);
          if (res.ok) await cache.put(url, res);
        } catch (_) {}
      }
    };
    await Promise.all(Array.from({ length: 6 }, worker));
  })().finally(() => { offlineDataJob = null; });
  return offlineDataJob;
}

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key)),
      ),
    ).then(() => self.clients.claim()),
  );
  // Not awaited by activation; kept alive by the next fetch below.
  cacheOfflineData();
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  // Only cache same-origin GETs — everything this app needs is same-origin
  // (bundled assets, app shell); cross-origin requests (if any) pass
  // through untouched.
  if (request.method !== 'GET') return;
  // Keep the worker alive while the background fill runs.
  event.waitUntil(cacheOfflineData());
  const origin = new URL(request.url).origin;
  // Flutter's fallback fonts come from Google's font servers; keep a copy
  // so text still renders offline (cache-first, they never change).
  const isFontCdn = origin === 'https://fonts.gstatic.com' ||
      origin === 'https://www.gstatic.com';
  if (origin !== self.location.origin && !isFontCdn) {
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
