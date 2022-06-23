const double homeLeftWidth = 280;

const int homeLeftTreeMaxLevel = 1;

const int loadTime = 280;

const uploadLimit = 30;

const isFileNameTip = '名称只能是中文、数字、字母、-、_的组合!';

const currentVersion = 'v1.2.2';

const initConfig = {
  "dataPath": "",
  "reservedDirectoryList": [
    "app_img_files_ads_cdefdf_abb_mlop",
    "app_link_files_ads_cdefdf_abb_mlop",
    "app_note_files_ads_cdefdf_abb_mlop",
    "app_video_files_ads_cdefdf_abb_mlop",
    "app_audio_files_ads_cdefdf_abb_mlop",
    "app_other_files_ads_cdefdf_abb_mlop"
  ],
  "linkFileDirectory": "app_link_files_ads_cdefdf_abb_mlop",
  "imgFileDirectory": "app_img_files_ads_cdefdf_abb_mlop",
  "noteFileDirectory": "app_note_files_ads_cdefdf_abb_mlop",
  "videoFileDirectory": "app_video_files_ads_cdefdf_abb_mlop",
  "audioFileDirectory": "app_audio_files_ads_cdefdf_abb_mlop",
  "otherFileDirectory": "app_other_files_ads_cdefdf_abb_mlop",
  "delMovePath": "",
  "audioExtensionList": [
    ".mp3",
    ".MP3",
    ".mpeg",
    ".MPEG",
    ".mpeg-4",
    ".MPEG-4",
    ".midi",
    ".MIDI",
    ".wma",
    ".WMA",
    ".wav",
    ".WAV",
    ".mppr",
    ".MPPR",
    ".asf",
    ".ASF",
    ".m4a",
    ".M4A",
    ".au",
    ".AU",
    ".ogg",
    ".OGG",
    ".oga",
    ".OGA",
    ".wv",
    ".WV",
    ".ra",
    ".RA"
  ],
  "videoExtensionList": [
    ".avi",
    ".AVI",
    ".mpg",
    ".MPG",
    ".wm",
    ".WM",
    ".wmv",
    ".WMV",
    ".wmp",
    ".WMP",
    ".mp4",
    ".MP4",
    ".mpeg",
    ".MPEG",
    ".rm",
    ".RM",
    ".rp",
    ".RP",
    ".rt",
    ".RT",
    ".rpm",
    ".RPM",
    ".rmvb",
    ".RMVB",
    ".mpe",
    ".MPE",
    ".dat",
    ".DAT",
    ".vob",
    ".VOB",
    ".mov",
    ".MOV",
    ".ram",
    ".RAM",
    ".smil",
    ".SMIL",
    ".scm",
    ".SCM"
  ],
  "imgExtensionList": [
    ".png",
    ".PNG",
    ".jpeg",
    ".JPEG",
    ".jpg",
    ".JPG",
    ".webp",
    ".WEBP",
    ".gif",
    ".GIF",
    ".bmp",
    ".BMP"
  ],
  "noteExtensionList": [
    ".doc",
    ".DOC",
    ".docx",
    ".DOCX",
    ".xls",
    ".XLS",
    ".xlsx",
    ".XLSX",
    ".txt",
    ".TXT",
    ".pdf",
    ".PDF",
    ".memo",
    '.MEMO'
  ],
  "noteSupportFileList": [
    {"key": "memo", "label": "添加备忘", "extension": ".memo"},
    {"key": "word", "label": "添加word", "extension": ".docx"},
    {"key": "excel", "label": "添加excel", "extension": ".xlsx"},
    {"key": "pdf", "label": "添加pdf", "extension": ".pdf"},
    {"key": "txt", "label": "添加txt", "extension": ".txt"}
  ]
};

const appTrayMenuKey = {
  'showApp': 'showApp',
  'minimizeApp': 'minimizeApp',
  'hideApp': 'hideApp',
  'exitApp': 'exitApp'
};
