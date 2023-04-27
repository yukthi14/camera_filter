
bool rippleEffect=false;
bool slide=false;
bool selectTimer = false;
bool slowMotion=false;
bool fps=false;
int currentIndex=0;
String selectedSong="";
bool containerOpened=true;

List musicName=['Kesariya','Ranjha','Pal','Kesariya','Ranjha','Pal','Kesariya','Ranjha','Pal','Kesariya','Ranjha','Pal'];
List musicArtists=["Arijit Singh","B Praak","Shreya Ghoshal","Arijit Singh","B Praak","Shreya Ghoshal","Arijit Singh","B Praak","Shreya Ghoshal","Arijit Singh","B Praak","Shreya Ghoshal"];
List posterImage=["https://imgs.search.brave.com/c_WUBzbeA200_CFOtq_chzndCtPI0xekQfDrg_f-wQQ/rs:fit:476:225:1/g:ce/aHR0cHM6Ly90c2Ux/LmV4cGxpY2l0LmJp/bmcubmV0L3RoP2lk/PU9JUC5mejFEa2xP/OU1lNWN5UlRKazFH/akF3SGFIWSZwaWQ9/QXBp",
  "https://imgs.search.brave.com/88-ykjiURasMLm3faQXOCRVL5B1JQPIi1sAUh1oHQV4/rs:fit:250:225:1/g:ce/aHR0cHM6Ly90c2Uz/Lm1tLmJpbmcubmV0/L3RoP2lkPU9JUC5E/MFV6NmJsSUtaT3Jt/TkVxLXczaFVnQUFB/QSZwaWQ9QXBp",
  "https://imgs.search.brave.com/5T_R4ECf7Ytbki0xBMuE07SeIbcK0nW_HZg-4nMmxOs/rs:fit:416:225:1/g:ce/aHR0cHM6Ly90c2Uy/Lm1tLmJpbmcubmV0/L3RoP2lkPU9JUC5W/NTNhWXRXWE9RZWRE/OVF4dTk1aWh3SGFJ/YiZwaWQ9QXBp",
  "https://imgs.search.brave.com/c_WUBzbeA200_CFOtq_chzndCtPI0xekQfDrg_f-wQQ/rs:fit:476:225:1/g:ce/aHR0cHM6Ly90c2Ux/LmV4cGxpY2l0LmJp/bmcubmV0L3RoP2lk/PU9JUC5mejFEa2xP/OU1lNWN5UlRKazFH/akF3SGFIWSZwaWQ9/QXBp",
  "https://imgs.search.brave.com/88-ykjiURasMLm3faQXOCRVL5B1JQPIi1sAUh1oHQV4/rs:fit:250:225:1/g:ce/aHR0cHM6Ly90c2Uz/Lm1tLmJpbmcubmV0/L3RoP2lkPU9JUC5E/MFV6NmJsSUtaT3Jt/TkVxLXczaFVnQUFB/QSZwaWQ9QXBp",
  "https://imgs.search.brave.com/5T_R4ECf7Ytbki0xBMuE07SeIbcK0nW_HZg-4nMmxOs/rs:fit:416:225:1/g:ce/aHR0cHM6Ly90c2Uy/Lm1tLmJpbmcubmV0/L3RoP2lkPU9JUC5W/NTNhWXRXWE9RZWRE/OVF4dTk1aWh3SGFJ/YiZwaWQ9QXBp",
  "https://imgs.search.brave.com/c_WUBzbeA200_CFOtq_chzndCtPI0xekQfDrg_f-wQQ/rs:fit:476:225:1/g:ce/aHR0cHM6Ly90c2Ux/LmV4cGxpY2l0LmJp/bmcubmV0L3RoP2lk/PU9JUC5mejFEa2xP/OU1lNWN5UlRKazFH/akF3SGFIWSZwaWQ9/QXBp",
  "https://imgs.search.brave.com/88-ykjiURasMLm3faQXOCRVL5B1JQPIi1sAUh1oHQV4/rs:fit:250:225:1/g:ce/aHR0cHM6Ly90c2Uz/Lm1tLmJpbmcubmV0/L3RoP2lkPU9JUC5E/MFV6NmJsSUtaT3Jt/TkVxLXczaFVnQUFB/QSZwaWQ9QXBp",
  "https://imgs.search.brave.com/5T_R4ECf7Ytbki0xBMuE07SeIbcK0nW_HZg-4nMmxOs/rs:fit:416:225:1/g:ce/aHR0cHM6Ly90c2Uy/Lm1tLmJpbmcubmV0/L3RoP2lkPU9JUC5W/NTNhWXRXWE9RZWRE/OVF4dTk1aWh3SGFJ/YiZwaWQ9QXBp",
  "https://imgs.search.brave.com/c_WUBzbeA200_CFOtq_chzndCtPI0xekQfDrg_f-wQQ/rs:fit:476:225:1/g:ce/aHR0cHM6Ly90c2Ux/LmV4cGxpY2l0LmJp/bmcubmV0L3RoP2lk/PU9JUC5mejFEa2xP/OU1lNWN5UlRKazFH/akF3SGFIWSZwaWQ9/QXBp",
  "https://imgs.search.brave.com/88-ykjiURasMLm3faQXOCRVL5B1JQPIi1sAUh1oHQV4/rs:fit:250:225:1/g:ce/aHR0cHM6Ly90c2Uz/Lm1tLmJpbmcubmV0/L3RoP2lkPU9JUC5E/MFV6NmJsSUtaT3Jt/TkVxLXczaFVnQUFB/QSZwaWQ9QXBp",
  "https://imgs.search.brave.com/5T_R4ECf7Ytbki0xBMuE07SeIbcK0nW_HZg-4nMmxOs/rs:fit:416:225:1/g:ce/aHR0cHM6Ly90c2Uy/Lm1tLmJpbmcubmV0/L3RoP2lkPU9JUC5W/NTNhWXRXWE9RZWRE/OVF4dTk1aWh3SGFJ/YiZwaWQ9QXBp",
];
List allSong=["audio/Kesariya.mp3","audio/Ranjha.mp3","audio/Pal-Ek-Pal(PaglaSongs).mp3",
  "audio/Kesariya.mp3","audio/Ranjha.mp3","audio/Pal-Ek-Pal(PaglaSongs).mp3",
  "audio/Kesariya.mp3","audio/Ranjha.mp3","audio/Pal-Ek-Pal(PaglaSongs).mp3",
  "audio/Kesariya.mp3","audio/Ranjha.mp3","audio/Pal-Ek-Pal(PaglaSongs).mp3"
];
