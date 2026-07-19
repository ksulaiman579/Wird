#!/usr/bin/env python3
"""Build assets/data/{hisnul_muslim.json, adhkar_morning_evening.json}.

islamhouse.com and hisnmuslim.com are both unreachable from this environment
(egress-blocked, same policy pattern as tanzil.net/sunnah.com — see
DATA_SOURCES.md), so this pulls from an open mirror of the Hisn al-Muslim
(Fortress of the Muslim) book instead: github.com/wafaaelmaandy/Hisn-Muslim-Json,
which bundles Arabic, English translation (Saheeh-International-style
wording — matches known Ayat al-Kursi renderings), and mostly-transliteration
in one place, with per-dua repetition counts. QA-scanned for encoding
corruption (none found) and missing fields (3 items out of 267 are missing
either their Arabic or English side and are dropped — logged below).

Run: python3 tool/build_dua_assets.py
"""
from __future__ import annotations

import json
import re
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DOWNLOADS = REPO_ROOT / "tool" / "downloads" / "dua"
SOURCE_FILE = DOWNLOADS / "husn_en.json"
SOURCE_URL = (
    "https://raw.githubusercontent.com/wafaaelmaandy/Hisn-Muslim-Json/"
    "master/husn_en.json"
)

DUA_OUT = REPO_ROOT / "assets" / "data" / "hisnul_muslim.json"
ADHKAR_OUT = REPO_ROOT / "assets" / "data" / "adhkar_morning_evening.json"

# The book presents morning and evening remembrance as a single combined
# chapter with time-specific wording ("asbahna/asbaha" = morning vs
# "amsayna/amsa" = evening) plus inline "[وإذا أمسى ...]" notes for the evening
# variant. split_morning_evening() below turns that one list into a clean
# morning list (asbaha form) and evening list (amsa form): unchanged Arabic is
# kept verbatim and only the source-documented tokens are swapped; the "when to
# say" cross-notes are dropped. Kept in sync with tool/split_adhkar.py.
ADHKAR_CHAPTER_ID = 27

# Arabic morning->evening token swaps, per dua id — exactly the substitutions the
# source states in its own bracketed evening notes.
_ADHKAR_AR_SUBS = {
    "hm-77": [("أَصْبَحْنَا وَأَصْبَحَ", "أَمْسَيْنَا وَأَمْسَى"),
              ("هَذَا الْيَوْمِ", "هَذِهِ اللَّيْلَةِ"), ("بَعْدَهُ", "بَعْدَهَا")],
    "hm-78": [("بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا", "بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا"),
              ("النُّشُورُ", "الْمَصِيرُ")],
    "hm-80": [("أَصْبَحْتُ", "أَمْسَيْتُ")],
    "hm-81": [("مَا أَصْبَحَ بِي", "مَا أَمْسَى بِي")],
    "hm-89": [("أَصْبَحْنَا وَأَصْبَحَ", "أَمْسَيْنَا وَأَمْسَى"),
              ("خَيْرَ هَذَا الْيَوْمِ", "خَيْرَ هَذِهِ اللَّيْلَةِ"),
              ("فَتْحَهُ، وَنَصْرَهُ، وَنورَهُ، وَبَرَكَتَهُ، وَهُدَاهُ",
               "فَتْحَهَا، وَنَصْرَهَا، وَنورَهَا، وَبَرَكَتَهَا، وَهُدَاهَا"),
              ("فِيهِ", "فِيهَا"), ("بَعْدَهُ", "بَعْدَهَا")],
    "hm-90": [("أَصْبَحْنا", "أَمْسَيْنا")],
}
# Clean explicit English translation (morning, evening) for the same ids.
_ADHKAR_TR = {
    "hm-77": (
        "‘We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah. None has the right to be worshipped except Allah, alone, without any partner, to Him belong all sovereignty and praise and He is over all things omnipotent. My Lord, I ask You for the good of this day and the good of what follows it and I take refuge in You from the evil of this day and the evil of what follows it. My Lord, I take refuge in You from laziness and senility. My Lord, I take refuge in You from torment in the Fire and punishment in the grave.’",
        "‘We have reached the evening and at this very time unto Allah belongs all sovereignty, and all praise is for Allah. None has the right to be worshipped except Allah, alone, without any partner, to Him belong all sovereignty and praise and He is over all things omnipotent. My Lord, I ask You for the good of this night and the good of what follows it and I take refuge in You from the evil of this night and the evil of what follows it. My Lord, I take refuge in You from laziness and senility. My Lord, I take refuge in You from torment in the Fire and punishment in the grave.’"),
    "hm-78": (
        "(O Allah, by Your leave we have reached the morning and by Your leave we have reached the evening, by Your leave we live and die and unto You is our resurrection.)",
        "(O Allah, by Your leave we have reached the evening and by Your leave we have reached the morning, by Your leave we live and die and unto You is our return.)"),
    "hm-80": (
        "(O Allah, verily I have reached the morning and call on You, the bearers of Your throne, Your angels, and all of Your creation to witness that You are Allah, none has the right to be worshipped except You, alone, without partner and that Muhammad is Your Servant and Messenger.) (four times)",
        "(O Allah, verily I have reached the evening and call on You, the bearers of Your throne, Your angels, and all of Your creation to witness that You are Allah, none has the right to be worshipped except You, alone, without partner and that Muhammad is Your Servant and Messenger.) (four times)"),
    "hm-81": (
        "(O Allah, whatever blessing has come to me this morning, or to any of Your creation, is from You alone, without partner, so for You is all praise and unto You all thanks.)",
        "(O Allah, whatever blessing has come to me this evening, or to any of Your creation, is from You alone, without partner, so for You is all praise and unto You all thanks.)"),
    "hm-89": (
        "(We have reached the morning and at this very time all sovereignty belongs to Allah, Lord of the worlds. O Allah, I ask You for the good of this day, its triumphs and its victories, its light and its blessings and its guidance, and I take refuge in You from the evil of this day and the evil that follows it.)",
        "(We have reached the evening and at this very time all sovereignty belongs to Allah, Lord of the worlds. O Allah, I ask You for the good of this night, its triumphs and its victories, its light and its blessings and its guidance, and I take refuge in You from the evil of this night and the evil that follows it.)"),
    "hm-90": (
        "(We rise upon the fitrah of Islam, and the word of pure faith, and upon the religion of our Prophet Muhammad, and the religion of our forefather Ibraheem, who was a Muslim and of true faith and was not of those who associate others with Allah.)",
        "(We rise upon the fitrah of Islam, and the word of pure faith, and upon the religion of our Prophet Muhammad, and the religion of our forefather Ibraheem, who was a Muslim and of true faith and was not of those who associate others with Allah.)"),
}
# Clean explicit transliteration (morning, evening) for the same ids.
_ADHKAR_TL = {
    "hm-77": (
        "Asbahna wa-asbahal-mulku lillah walhamdu lillah la ilaha illal-lah, wahdahu la shareeka lah, lahul-mulku walahul-hamd, wahuwa AAala kulli shayin qadeer, rabbi as-aluka khayra ma fee hathal-yawm, wakhayra ma baAAdah, wa-aAAoothu bika min sharri hathal-yawm, washarri ma baAAdah, rabbi aAAoothu bika minal-kasal, wasoo-il kibar, rabbi aAAoothu bika min AAathabin fin-nar, waAAathabin fil-qabr.",
        "Amsayna wa-amsal-mulku lillah walhamdu lillah la ilaha illal-lah, wahdahu la shareeka lah, lahul-mulku walahul-hamd, wahuwa AAala kulli shayin qadeer, rabbi as-aluka khayra ma fee hathihil-laylah, wakhayra ma baAAdaha, wa-aAAoothu bika min sharri hathihil-laylah, washarri ma baAAdaha, rabbi aAAoothu bika minal-kasal, wasoo-il kibar, rabbi aAAoothu bika min AAathabin fin-nar, waAAathabin fil-qabr."),
    "hm-78": (
        "Allahumma bika asbahna wabika amsayna, wabika nahya, wabika namootu wa-ilaykan-nushoor.",
        "Allahumma bika amsayna wabika asbahna, wabika nahya, wabika namootu wa-ilaykal-maseer."),
    "hm-80": (
        "Allahumma innee asbahtu oshhiduk, wa-oshhidu hamalata AAarshik, wamala-ikatak, wajameeAAa khalqik, annaka antal-lahu la ilaha illa ant, wahdaka la shareeka lak, wa-anna Muhammadan AAabduka warasooluk. (four times)",
        "Allahumma innee amsaytu oshhiduk, wa-oshhidu hamalata AAarshik, wamala-ikatak, wajameeAAa khalqik, annaka antal-lahu la ilaha illa ant, wahdaka la shareeka lak, wa-anna Muhammadan AAabduka warasooluk. (four times)"),
    "hm-81": (
        "Allahumma ma asbaha bee min niAAmatin, aw bi-ahadin min khalqik, faminka wahdaka la shareeka lak, falakal-hamdu walakash-shukr.",
        "Allahumma ma amsa bee min niAAmatin, aw bi-ahadin min khalqik, faminka wahdaka la shareeka lak, falakal-hamdu walakash-shukr."),
    "hm-89": (
        "Asbahna wa-asbahal-mulku lillahi rabbil-AAalameen, allahumma innee as-aluka khayra hathal-yawm, fat-hahu, wanasrahu, wanoorahu, wabarakatahu, wahudahu, wa-aAAoothu bika min sharri ma feehi, washarri ma baAAdah.",
        "Amsayna wa-amsal-mulku lillahi rabbil-AAalameen, allahumma innee as-aluka khayra hathihil-laylah, fat-haha, wanasraha, wanooraha, wabarakataha, wahudaha, wa-aAAoothu bika min sharri ma feeha, washarri ma baAAdaha."),
    "hm-90": (
        "Asbahna AAala fitratil-islam, waAAala kalimatil-ikhlas, waAAala deeni nabiyyina Muhammad, waAAala millati abeena Ibraheem, haneefan musliman wama kana minal-mushrikeen.",
        "Amsayna AAala fitratil-islam, waAAala kalimatil-ikhlas, waAAala deeni nabiyyina Muhammad, waAAala millati abeena Ibraheem, haneefan musliman wama kana minal-mushrikeen."),
}
_ADHKAR_BRACKET = re.compile(r"\s*\[[^\]]*\]")
_ADHKAR_RUBRIC_AR = [("مائةَ مرَّةٍ إذا أصبحَ", "مائةَ مرَّةٍ"),
                     ("ثلاثَ مرَّاتٍ إذا أصبحَ", "ثلاثَ مرَّاتٍ"),
                     ("ثلاثَ مرَّاتٍ إذا أمسى", "ثلاثَ مرَّاتٍ"),
                     (" إذا أصبحَ", ""), (" إذا أمسى", "")]
_ADHKAR_RUBRIC_EN = [("(one hundred times every day)", "(one hundred times)"),
                     ("(three times in the evening)", "(three times)"),
                     ("(three times in the morning)", "(three times)")]


def _apply(text: str, subs) -> str:
    for a, b in subs:
        text = text.replace(a, b)
    return text


def split_morning_evening(items: list[dict]) -> tuple[list[dict], list[dict]]:
    """Turn the combined adhkar chapter into distinct morning/evening lists."""
    morning, evening = [], []
    for e in items:
        mid = e["id"]
        m, v = dict(e), dict(e)
        if mid in _ADHKAR_AR_SUBS:
            m_ar = _ADHKAR_BRACKET.sub("", e["arabic"]).strip()
            e_ar = _apply(m_ar, _ADHKAR_AR_SUBS[mid])
            if e_ar == m_ar:
                raise SystemExit(f"FAIL: adhkar split for {mid} changed nothing")
            m.update(arabic=m_ar, translation=_ADHKAR_TR[mid][0],
                     transliteration=_ADHKAR_TL[mid][0])
            v.update(arabic=e_ar, translation=_ADHKAR_TR[mid][1],
                     transliteration=_ADHKAR_TL[mid][1])
        else:
            ar2 = _apply(_ADHKAR_BRACKET.sub("", e["arabic"]).strip(), _ADHKAR_RUBRIC_AR)
            tr2 = _apply(e["translation"], _ADHKAR_RUBRIC_EN)
            tl2 = _apply(e["transliteration"], _ADHKAR_RUBRIC_EN) if e["transliteration"] else None
            m.update(arabic=ar2, translation=tr2, transliteration=tl2)
            v.update(arabic=ar2, translation=tr2, transliteration=tl2)
        for o in (m, v):
            o["wordCount"] = word_count(o["arabic"])
        morning.append(m)
        evening.append(v)
    return morning, evening

# Items whose "transliteration" field is actually a Quran-recitation
# reference note, not a transliteration (the ayah is already fully quoted
# in ARABIC_TEXT) — verified by reading each one, not guessed by regex alone.
NOTE_NOT_TRANSLITERATION_IDS = {75, 100, 101}


def ensure_source() -> None:
    DOWNLOADS.mkdir(parents=True, exist_ok=True)
    if SOURCE_FILE.exists():
        return
    print(f"Fetching {SOURCE_URL} -> {SOURCE_FILE} ...")
    with urllib.request.urlopen(SOURCE_URL, timeout=30) as resp:
        SOURCE_FILE.write_bytes(resp.read())


def word_count(arabic: str) -> int:
    return len([w for w in arabic.split() if w.strip()])


def build_dua(item: dict, chapter_title: str) -> dict | None:
    arabic = item.get("ARABIC_TEXT", "").strip()
    translation = item.get("TRANSLATED_TEXT", "").strip()
    if not arabic or not translation:
        print(f"SKIP: dua item {item.get('ID')} missing arabic or translation")
        return None

    transliteration = item.get("LANGUAGE_ARABIC_TRANSLATED_TEXT", "").strip()
    if item["ID"] in NOTE_NOT_TRANSLITERATION_IDS or not transliteration:
        transliteration = None

    return {
        "id": f"hm-{item['ID']}",
        "arabic": arabic,
        "transliteration": transliteration,
        "translation": translation,
        "reference": f"Hisn al-Muslim (Fortress of the Muslim) — {chapter_title}",
        "repetitions": item.get("REPEAT", 1),
        "wordCount": word_count(arabic),
    }


def build() -> None:
    ensure_source()
    DUA_OUT.parent.mkdir(parents=True, exist_ok=True)

    data = json.loads(SOURCE_FILE.read_text(encoding="utf-8-sig"))
    chapters = data["English"]

    if len(chapters) != 132:
        raise SystemExit(f"FAIL: expected 132 chapters, got {len(chapters)}")

    categories = []
    adhkar_items = None

    for chapter in sorted(chapters, key=lambda c: c["ID"]):
        duas = [
            d
            for item in chapter["TEXT"]
            if (d := build_dua(item, chapter["TITLE"])) is not None
        ]
        if not duas:
            print(f"SKIP: chapter {chapter['ID']} ({chapter['TITLE']}) has no usable duas left")
            if chapter["ID"] == ADHKAR_CHAPTER_ID:
                raise SystemExit("FAIL: the adhkar chapter itself ended up empty")
            continue

        categories.append(
            {
                "id": f"hm-cat-{chapter['ID']}",
                "titleEnglish": chapter["TITLE"],
                "order": chapter["ID"],
                "duas": duas,
            }
        )
        if chapter["ID"] == ADHKAR_CHAPTER_ID:
            adhkar_items = duas

    if adhkar_items is None:
        raise SystemExit(f"FAIL: adhkar chapter {ADHKAR_CHAPTER_ID} not found")

    total_duas = sum(len(c["duas"]) for c in categories)

    DUA_OUT.write_text(
        json.dumps({"categories": categories}, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    morning_items, evening_items = split_morning_evening(adhkar_items)
    ADHKAR_OUT.write_text(
        json.dumps(
            {"morning": morning_items, "evening": evening_items},
            ensure_ascii=False,
            separators=(",", ":"),
        ),
        encoding="utf-8",
    )

    print(
        f"OK: wrote {DUA_OUT.relative_to(REPO_ROOT)} "
        f"({len(categories)} categories, {total_duas} duas) and "
        f"{ADHKAR_OUT.relative_to(REPO_ROOT)} ({len(adhkar_items)} items x2)."
    )


if __name__ == "__main__":
    build()
