#!/usr/bin/env python3
"""Local, offline, start/stop machine-translation of the app's ARB locales.

Fills the ~85%-English non-en/ar locale ARBs with Meta's NLLB-200 — one
multilingual model covering all of this app's languages, including low-resource
ones (Hausa, Yoruba, Sindhi, Pashto, Uyghur, Dhivehi) that general LLMs handle
poorly. Default model: facebook/nllb-200-distilled-1.3B.

Start/stop, resumable, and resource-aware — designed to coexist with a GPU
corpus builder (Tesseract / EasyOCR / Qwen2.5-VL). Pattern borrowed (for
inspiration only) from the Resources corpus builder's pidfile + safe-stop
approach.

  python tool/translate_arb.py status            # progress + what's left
  python tool/translate_arb.py start             # CPU (GPU stays free), resumable
  python tool/translate_arb.py start --device cuda   # ONLY when the GPU is idle
  python tool/translate_arb.py stop              # safe stop (exact-PID, verified)

Resource notes:
  * Default --device cpu keeps the GPU 100% free for your corpus builder. NLLB
    1.3B (~3GB) CANNOT share 8GB with a 7B VLM, so cuda is opt-in and guarded
    (auto-falls back to CPU if free VRAM < --vram-cap-gb).
  * --threads caps CPU threads (default: half the cores) so Tesseract keeps some.
  * Checkpoints after every batch: a stop (even a hard kill) loses at most one
    batch; re-running `start` resumes (already-translated keys are skipped).

Safety: ICU plural/select messages are skipped (MT corrupts the syntax);
placeholders ({name}) are protected + verified (broken ones fall back to
English); a brand/Islamic glossary is left untranslated. Machine output —
especially religious terms — should get a native-speaker review before release.
"""
import argparse
import json
import os
import re
import signal
import sys
import time

BASE = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
L10N_DIR = os.path.join(BASE, "lib", "l10n")
PID_FILE = os.path.join(BASE, ".translate_arb.pid")
STATE_FILE = os.path.join(BASE, ".translate_arb_state.json")
TEMPLATE = "en"
FROZEN = {"en", "ar"}  # already fully translated — never touch
# The UI ships in these locales only (see lib/core/prefs/app_language_provider
# .dart `shipLocaleCodes`). Translate ONLY these — the dropped locales aren't
# user-selectable, so don't waste effort on them.
SHIP_LOCALES = ["en", "ar", "ur", "hi", "bn", "ml", "fil"]

FLORES = {
    "am": "amh_Ethi", "az": "azj_Latn", "bg": "bul_Cyrl", "bn": "ben_Beng",
    "bs": "bos_Latn", "ckb": "ckb_Arab", "cs": "ces_Latn", "da": "dan_Latn",
    "de": "deu_Latn", "dv": "div_Thaa", "el": "ell_Grek", "es": "spa_Latn",
    "fa": "pes_Arab", "fi": "fin_Latn", "fil": "tgl_Latn", "fr": "fra_Latn",
    "gu": "guj_Gujr", "ha": "hau_Latn", "hi": "hin_Deva", "hu": "hun_Latn",
    "id": "ind_Latn", "it": "ita_Latn", "ja": "jpn_Jpan", "kk": "kaz_Cyrl",
    "km": "khm_Khmr", "kn": "kan_Knda", "ko": "kor_Hang", "ku": "kmr_Latn",
    "ky": "kir_Cyrl", "ml": "mal_Mlym", "mr": "mar_Deva", "ms": "zsm_Latn",
    "my": "mya_Mymr", "nb": "nob_Latn", "ne": "npi_Deva", "nl": "nld_Latn",
    "pa": "pan_Guru", "pl": "pol_Latn", "ps": "pbt_Arab", "pt": "por_Latn",
    "ro": "ron_Latn", "ru": "rus_Cyrl", "sd": "snd_Arab", "si": "sin_Sinh",
    "so": "som_Latn", "sq": "als_Latn", "sr": "srp_Cyrl", "sv": "swe_Latn",
    "sw": "swh_Latn", "ta": "tam_Taml", "te": "tel_Telu", "tg": "tgk_Cyrl",
    "th": "tha_Thai", "tk": "tuk_Latn", "tr": "tur_Latn", "ug": "uig_Arab",
    "uk": "ukr_Cyrl", "ur": "urd_Arab", "uz": "uzn_Latn", "vi": "vie_Latn",
    "yo": "yor_Latn", "zh": "zho_Hans",
}

# Values that must stay verbatim (brand + Islamic terms whose transliteration
# is standard/preferred, and short UI words NLLB mistranslates out of context,
# e.g. "Session" -> "Résolution du Conseil"). Whole-string match only, so a
# term embedded mid-sentence still translates (documented; needs review).
GLOSSARY = {
    "Wird", "Al-Manhaj", "Al-Fatiha", "An-Nas", "Al-Falaq", "PayPal",
    "Buy Me a Coffee", "Sabaq", "Sabqi", "Manzil", "Nawawi", "Hisnul-Muslim",
    "Sahih Bukhari", "Sahih Muslim", "IslamHouse",
    # Islamic terms — keep as transliteration
    "Hadith", "Tasbih", "Qibla", "Zakah", "Adhkar", "Dua", "Duas", "Surah",
    "Ayah", "Juz", "Tajweed", "Dhikr", "Mushaf", "Sunnah", "Salaf", "Ramadan",
    "Asma-ul-Husna", "Fajr", "Dhuhr", "Asr", "Maghrib", "Isha", "Adhan",
    # short UI words NLLB mis-senses out of context (leave EN, review later)
    "Session", "Explore", "More",
}

PLACEHOLDER = re.compile(r"\{[a-zA-Z0-9_]+\}")
ICU = re.compile(r"\{[^}]*,\s*(?:plural|select)\s*,")
SENT = "⸤{}⸥"

_stop = False


def _on_signal(_sig, _frame):
    global _stop
    _stop = True
    print("\n[stop] finishing current batch and checkpointing…", flush=True)


def is_translatable(key, value):
    if key.startswith("@") or not isinstance(value, str):
        return False
    if value.strip() in GLOSSARY or ICU.search(value):
        return False
    return bool(re.search(r"[A-Za-z]", value))


def protect(s):
    phs = PLACEHOLDER.findall(s)
    for i, p in enumerate(phs):
        s = s.replace(p, SENT.format(i), 1)
    return s, phs


def restore(s, phs):
    for i, p in enumerate(phs):
        s = s.replace(SENT.format(i), p)
    return s


def load(loc):
    with open(os.path.join(L10N_DIR, f"app_{loc}.arb"), encoding="utf-8") as f:
        return json.load(f)


def save_arb(loc, data):
    with open(os.path.join(L10N_DIR, f"app_{loc}.arb"), "w",
              encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def read_state():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, encoding="utf-8") as f:
            return json.load(f)
    return {}


def write_state(state):
    with open(STATE_FILE, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)


def en_strings():
    en = load(TEMPLATE)
    return en, {k: v for k, v in en.items() if is_translatable(k, v)}


def todo_for(loc, en_str):
    data = load(loc)
    return data, [k for k, v in en_str.items()
                  if data.get(k) is None or data.get(k) == v]


def cmd_status(args):
    en, en_str = en_strings()
    icu = [k for k, v in en.items()
           if not k.startswith("@") and isinstance(v, str) and ICU.search(v)]
    targets = [l for l in SHIP_LOCALES if l not in FROZEN]
    print(f"template en: {len(en_str)} translatable strings "
          f"(+{len(icu)} ICU keys skipped)\n")
    total_left = 0
    for loc in targets:
        try:
            _, todo = todo_for(loc, en_str)
        except FileNotFoundError:
            continue
        total_left += len(todo)
        bar = "done" if not todo else f"{len(todo)} left"
        print(f"  {loc:4} {FLORES[loc]:10} {bar}")
    running = _running_pid()
    print(f"\n total strings remaining: {total_left}")
    print(f" worker: {'RUNNING pid ' + str(running) if running else 'stopped'}")
    return 0


def _running_pid():
    if not os.path.exists(PID_FILE):
        return None
    try:
        pid = int(open(PID_FILE, encoding="utf-8").read().strip())
    except (OSError, ValueError):
        return None
    try:
        import psutil
        if psutil.pid_exists(pid) and "translate_arb" in " ".join(
                psutil.Process(pid).cmdline()):
            return pid
    except Exception:
        return pid  # best effort
    return None


def cmd_stop(args):
    # Mirrors the corpus builder's safe-stop: exact PID, verify cmdline, kill
    # the tree once, clean up. No pattern-matching process scans.
    if not os.path.exists(PID_FILE):
        print("[stop] no pidfile — worker isn't running (or already finished).")
        return 0
    try:
        pid = int(open(PID_FILE, encoding="utf-8").read().strip())
    except (OSError, ValueError) as e:
        print(f"[stop] pidfile unreadable ({e}); delete {PID_FILE} if stale.")
        return 1
    try:
        import psutil
    except ImportError:
        print("[stop] psutil not installed: pip install psutil")
        return 1
    if not psutil.pid_exists(pid):
        print(f"[stop] PID {pid} not running; cleaning stale pidfile.")
        _rm(PID_FILE)
        return 0
    proc = psutil.Process(pid)
    if "translate_arb" not in " ".join(proc.cmdline()):
        print(f"[stop] PID {pid} is not this tool (reused PID). Refusing to kill.")
        return 1
    print(f"[stop] stopping PID {pid} and children…")
    kids = proc.children(recursive=True)
    for p in kids + [proc]:
        try:
            p.terminate()
        except psutil.NoSuchProcess:
            pass
    gone, alive = psutil.wait_procs(kids + [proc], timeout=6)
    for p in alive:
        try:
            p.kill()
        except psutil.NoSuchProcess:
            pass
    _rm(PID_FILE)
    print(f"[stop] done ({len(gone)} graceful, {len(alive)} forced). "
          "Re-run `start` to resume — completed strings are skipped.")
    return 0


def _rm(path):
    try:
        os.remove(path)
    except OSError:
        pass


def cmd_start(args):
    if _running_pid():
        print(f"[start] already running (pid {_running_pid()}). Use `stop` first.")
        return 1
    # Reduce CUDA fragmentation (the OOM message's own suggestion).
    os.environ.setdefault("PYTORCH_CUDA_ALLOC_CONF", "expandable_segments:True")
    import torch
    from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

    threads = args.threads or max(1, (os.cpu_count() or 2) // 2)
    os.environ.setdefault("OMP_NUM_THREADS", str(threads))
    torch.set_num_threads(threads)

    device = args.device
    if device == "cuda":
        if not torch.cuda.is_available():
            print("[start] cuda unavailable — using cpu"); device = "cpu"
        else:
            free, total = torch.cuda.mem_get_info()
            if free / 1e9 < args.vram_cap_gb:
                print(f"[start] only {free/1e9:.1f}GB VRAM free — using cpu "
                      "(won't fight your corpus builder)"); device = "cpu"
            else:
                torch.cuda.set_per_process_memory_fraction(
                    min(1.0, args.vram_cap_gb / (total / 1e9)))

    signal.signal(signal.SIGINT, _on_signal)
    try:
        signal.signal(signal.SIGTERM, _on_signal)
    except (ValueError, AttributeError):
        pass

    with open(PID_FILE, "w", encoding="utf-8") as f:
        f.write(str(os.getpid()))
    try:
        # fp16 on GPU halves the weights (~5.2GB fp32 → ~2.6GB) so the 1.3B
        # model fits an 8GB card with room for a batch; fp32 on CPU.
        dtype = torch.float16 if device == "cuda" else torch.float32
        print(f"[start] loading {args.model} on {device} ({dtype}, "
              f"threads={threads})…", flush=True)
        tok = AutoTokenizer.from_pretrained(args.model)
        model = AutoModelForSeq2SeqLM.from_pretrained(
            args.model, torch_dtype=dtype).to(device)

        en, en_str = en_strings()
        state = read_state()
        targets = (args.locales.split(",") if args.locales
                   else [l for l in SHIP_LOCALES if l not in FROZEN])

        for loc in targets:
            if _stop:
                break
            if loc not in FLORES:
                print(f"[skip] {loc}: no FLORES mapping"); continue
            data, todo = todo_for(loc, en_str)
            if args.limit:
                todo = todo[:args.limit]  # smoke-test cap
            if not todo:
                state[loc] = {"done": True, "updated_at": _now()}
                write_state(state); continue
            print(f"[{loc}] {FLORES[loc]}: {len(todo)} to translate", flush=True)
            tok.src_lang = "eng_Latn"
            bos = tok.convert_tokens_to_ids(FLORES[loc])
            done_n = 0
            for i in range(0, len(todo), args.batch):
                if _stop:
                    break
                keys = todo[i:i + args.batch]
                prot = [protect(en_str[k]) for k in keys]
                enc = tok([p[0] for p in prot], return_tensors="pt",
                          padding=True, truncation=True)
                enc = {k: v.to(device) for k, v in enc.items()}
                out = model.generate(**enc, forced_bos_token_id=bos,
                                     max_length=512)
                dec = tok.batch_decode(out, skip_special_tokens=True)
                for k, (_, phs), tr in zip(keys, prot, dec):
                    r = restore(tr, phs)
                    if all(SENT.format(j) not in r for j in range(len(phs))) \
                            and all(p in r for p in phs):
                        data[k] = r
                        done_n += 1
                save_arb(loc, data)  # checkpoint every batch → hard-stop-safe
                sys.stdout.write(f"\r  {min(i+args.batch,len(todo))}/{len(todo)}")
                sys.stdout.flush()
            print()
            _, remaining = todo_for(loc, en_str)
            state[loc] = {"done": not remaining, "translated": done_n,
                          "updated_at": _now()}
            write_state(state)
        if _stop:
            print("[start] paused. Re-run `start` to resume.")
        else:
            print("[start] all locales done. Run `flutter gen-l10n`, review, "
                  "then `flutter analyze`.")
    finally:
        _rm(PID_FILE)
    return 0


def _now():
    return time.strftime("%Y-%m-%dT%H:%M:%S")


def main():
    ap = argparse.ArgumentParser(description="Local start/stop ARB translator")
    sub = ap.add_subparsers(dest="cmd", required=True)
    st = sub.add_parser("start", help="translate (resumable)")
    st.add_argument("--locales", help="comma list, e.g. fr,ur (default: all)")
    st.add_argument("--model", default="facebook/nllb-200-distilled-1.3B")
    st.add_argument("--device", choices=["cpu", "cuda"], default="cpu")
    st.add_argument("--threads", type=int, default=0)
    st.add_argument("--vram-cap-gb", type=float, default=5.0)
    st.add_argument("--batch", type=int, default=8)
    st.add_argument("--limit", type=int, default=0,
                    help="cap strings per locale (smoke-testing only)")
    st.set_defaults(fn=cmd_start)
    sub.add_parser("stop", help="safe stop").set_defaults(fn=cmd_stop)
    sub.add_parser("status", help="progress").set_defaults(fn=cmd_status)
    args = ap.parse_args()
    return args.fn(args)


if __name__ == "__main__":
    sys.exit(main())
