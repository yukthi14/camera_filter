bool rippleEffect = false;
bool slide = false;
bool selectTimer = false;
bool slowMotion = false;
bool fps = false;
int currentIndex = 0;
String selectedSong = "";
bool containerOpened = true;
String poster =
    'https://imgs.search.brave.com/c_WUBzbeA200_CFOtq_chzndCtPI0xekQfDrg_f-wQQ/rs:fit:476:225:1/g:ce/aHR0cHM6Ly90c2Ux/LmV4cGxpY2l0LmJp/bmcubmV0L3RoP2lk/PU9JUC5mejFEa2xP/OU1lNWN5UlRKazFH/akF3SGFIWSZwaWQ9/QXBp';
String songName = 'Kesariya - Arijit Singh';
String artistName = '';

List musicName = [
  'Kesariya',
  'Ranjha',
  'Pal',
  'Kesariya',
  'Ranjha',
  'Pal',
  'Kesariya',
  'Ranjha',
  'Pal',
  'Kesariya',
  'Ranjha',
  'Pal'
];
List musicArtists = [
  "Arijit Singh",
  "B Praak",
  "Shreya Ghoshal",
  "Arijit Singh",
  "B Praak",
  "Shreya Ghoshal",
  "Arijit Singh",
  "B Praak",
  "Shreya Ghoshal",
  "Arijit Singh",
  "B Praak",
  "Shreya Ghoshal"
];
List posterImage = [
  "assets/poster1.webp",
  "assets/poster2.webp",
  "assets/poster3.jpg",
  "assets/poster1.webp",
  "assets/poster2.webp",
  "assets/poster3.jpg",
  "assets/poster1.webp",
  "assets/poster2.webp",
  "assets/poster3.jpg",
  "assets/poster1.webp",
  "assets/poster2.webp",
  "assets/poster3.jpg",
];
List allSong = [
  "audio/Kesariya.mp3",
  "audio/Ranjha.mp3",
  "audio/Pal-Ek-Pal(PaglaSongs).mp3",
  "audio/Kesariya.mp3",
  "audio/Ranjha.mp3",
  "audio/Pal-Ek-Pal(PaglaSongs).mp3",
  "audio/Kesariya.mp3",
  "audio/Ranjha.mp3",
  "audio/Pal-Ek-Pal(PaglaSongs).mp3",
  "audio/Kesariya.mp3",
  "audio/Ranjha.mp3",
  "audio/Pal-Ek-Pal(PaglaSongs).mp3"
];

List langEnglish = [
  "All",
  "Italian",
  "Russian",
  "Marathi",
  "English",
  "German",
  "Turkish",
  "Telugu",
  "Kannada",
  "French",
  "Arabic",
  "portuguese",
  "Indonesian",
  "Hindi",
  "Spanish",
  "Malayalam",
  "Urdu",
  "Korean",
  "Japanese",
  "Tamil",
  // "Haryanvi",
  "Bengali",
  "Bhojpuri",
  "Chinese",
  "Punjabi"
];

List lang = [
  "All",
  "عربي",
  "বাংলা",
  "भोजपुरी",
  "中国人",
  "english",
  "français",
  "Deutsch",
  "हिंदी",
  "bahasa Indonesia",
  "italiano",
  "日本",
  "ಕನ್ನಡ",
  "한국인",
  "മലയാളം",
  "मराठी",
  "ਪੰਜਾਬੀ",
  "русский",
  "Español",
  "தமிழ்",
  "తెలుగు",
  "Türkçe",
  "اردو",
  "português",
];
