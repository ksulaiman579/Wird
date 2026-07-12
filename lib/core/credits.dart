/// Every upstream content/data source this app bundles or downloads from,
/// with a link — surfaced in-app (About → Credits) and mirrored in
/// `README.md`'s Credits & Acknowledgements section (M17.2/M17.3). Keep
/// this list and `DATA_SOURCES.md`'s license-summary table in sync: every
/// row there should have a matching entry here, and vice versa.
library;

class CreditEntry {
  const CreditEntry({required this.name, required this.url, required this.note});

  final String name;
  final String url;
  final String note;
}

const List<CreditEntry> credits = [
  CreditEntry(
    name: 'fawazahmed0 / quran-api & hadith-api',
    url: 'https://github.com/fawazahmed0/quran-api',
    note: 'Additional Quran translation packs, the Nawawi English '
        'translation, and the six downloadable Hadith collections.',
  ),
  CreditEntry(
    name: 'risan / quran-json',
    url: 'https://github.com/risan/quran-json',
    note: 'Bundled Quran Arabic text, English translation, and '
        'transliteration (CC BY-SA 4.0).',
  ),
  CreditEntry(
    name: 'semarketir / quranjson',
    url: 'https://github.com/semarketir/quranjson',
    note: 'Juz (para) boundary metadata (MIT).',
  ),
  CreditEntry(
    name: 'AhmedBaset / hadith-json',
    url: 'https://github.com/AhmedBaset/hadith-json',
    note: '40 Hadith of an-Nawawi Arabic text and narrator attribution '
        '(ISC).',
  ),
  CreditEntry(
    name: 'AbdelrahmanEid / Hadith-Data-Sets',
    url: 'https://github.com/AbdelrahmanEid/Hadith-Data-Sets',
    note: 'Independent Nine Books Arabic corpus, used to cross-check the '
        'bundled hadith text.',
  ),
  CreditEntry(
    name: 'wafaaelmaandy / Hisn-Muslim-Json',
    url: 'https://github.com/wafaaelmaandy/Hisn-Muslim-Json',
    note: 'Hisnul Muslim & daily adhkar text.',
  ),
  CreditEntry(
    name: 'Tanzil.net',
    url: 'https://tanzil.net',
    note: 'The original Quran text/translation project the bundled '
        'Uthmani encoding and transliteration are ultimately sourced '
        'from.',
  ),
  CreditEntry(
    name: 'IslamHouse',
    url: 'https://islamhouse.com',
    note: 'Original publisher of Hisnul Muslim, and the source of the '
        'Knowledge Library books (downloaded on demand from IslamHouse\'s '
        'CDN) — the da\'wah-publishing arm of the Saudi Ministry of '
        'Islamic Affairs (Rabwah).',
  ),
  CreditEntry(
    name: 'everyayah.com',
    url: 'https://everyayah.com',
    note: 'Per-ayah recitation audio — 18 reciters incl. Husary, '
        'Alafasy, Abdul Basit, Minshawi, Sudais, and Shuraim.',
  ),
  CreditEntry(
    name: 'AlAdhan API / adhan_dart',
    url: 'https://aladhan.com/prayer-times-api',
    note: 'Prayer-time calculation (online calendar + offline fallback).',
  ),
  CreditEntry(
    name: 'dr5hn / countries-states-cities-database',
    url: 'https://github.com/dr5hn/countries-states-cities-database',
    note: 'City list used for prayer-time location (ODbL).',
  ),
  CreditEntry(
    name: 'KFGQPC Uthmanic Hafs font',
    url: 'https://github.com/mustafa0x/qpc-fonts',
    note: 'King Fahd Glorious Qur\'an Printing Complex — the Quran '
        'display font.',
  ),
  CreditEntry(
    name: 'Adhan recording (Adam-synagda)',
    url: 'https://commons.wikimedia.org/wiki/File:Beautiful_adhan.ogg',
    note: 'The bundled adhan notification tone (CC0 1.0, Wikimedia '
        'Commons).',
  ),
  CreditEntry(
    name: 'Azan-MCP',
    url: 'https://github.com/azan-mcp',
    note: 'The 99 Names of Allah (Asma ul-Husna) data — Arabic, '
        'transliteration, meaning, and explanations (MIT).',
  ),
];
