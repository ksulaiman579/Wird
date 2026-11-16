# Speed (2026-11-16)

**Android emulator** (x86_64, release build):
- Cold start to first frame: 2.8 s, 2.3 s and 2.3 s in three runs. Android flags 5 s or more as slow.
- Memory after start: about 140 MB.
- arm64 APK: 42 MB.

**Web** (wird-alpha.vercel.app, in-app browser):
- First visit: 5.3 MB in 16 requests from 2 hosts. Load event at about 1.5 s.
- The offline cache holds the app shell and CanvasKit. See WQA-032 for what it misses.

**Not measured:** reader frame times while audio plays, opening a big hadith collection, and a long reading session. These need DevTools profiling on a real phone.
