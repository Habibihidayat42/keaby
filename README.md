# Keaby - Honeycomb Fishing Script

GUI bertema sarang lebah untuk Roblox fishing automation dengan desain yang indah dan responsive untuk semua platform (Android, iOS, PC).

## Fitur Utama

### GUI Features
- **Tema Sarang Lebah**: Desain hexagonal dengan warna madu yang cantik
- **Draggable Window**: Geser window dari bagian header atas
- **Minimize Button**: Minimize ke icon lebah kecil yang bisa diklik untuk restore
- **Resizable Window**: Resize window dengan drag pojok kanan bawah
- **Responsive**: Bekerja sempurna di Android (touch), iOS (touch), dan PC (mouse)

### Fishing Features
1. **Instant Fishing**
   - Toggle ON/OFF
   - 3 Slider Settings (muncul saat aktif):
     - Hook Delay (0.01s - 0.25s)
     - Fishing Delay (0.05s - 1.0s)
     - Cancel Delay (0.01s - 0.25s)

2. **Instant 2x Speed**
   - Toggle ON/OFF
   - 2 Slider Settings (muncul saat aktif):
     - Fishing Delay (0.0s - 1.0s)
     - Cancel Delay (0.01s - 0.2s)

## Cara Menggunakan

### Method 1: Load dari GitHub (Recommended)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/main/KeabyGUI.lua"))()
```

### Method 2: Copy Paste Script
1. Copy isi file `KeabyGUI.lua`
2. Paste ke executor Roblox Anda
3. Execute script

## Struktur Project

```
keaby/
├── KeabyGUI.lua              # Main GUI file (execute this)
├── FungsiKeaby/
│   ├── InstantFishing.lua    # Instant Fishing logic (no GUI)
│   └── Instant2Xspeed.lua    # Instant 2x Speed logic (no GUI)
└── README.md                 # Documentation
```

## Kontrol GUI

### Desktop (PC)
- **Drag**: Klik dan drag header untuk memindahkan window
- **Resize**: Klik dan drag pojok kanan bawah untuk resize
- **Slider**: Klik dan drag slider atau klik posisi untuk set value
- **Minimize**: Klik tombol "_" di header

### Mobile (Android/iOS)
- **Drag**: Touch dan drag header untuk memindahkan window
- **Resize**: Touch dan drag pojok kanan bawah untuk resize
- **Slider**: Touch dan drag slider atau tap posisi untuk set value
- **Minimize**: Tap tombol "_" di header

## Cara Kerja

1. Saat script di-execute, GUI langsung muncul di halaman Main
2. Pilih fitur yang ingin diaktifkan (Instant Fishing atau Instant 2x Speed)
3. Klik toggle untuk mengaktifkan fitur
4. Slider akan muncul untuk mengatur delay settings
5. Adjust slider sesuai kecepatan rod Anda
6. Fitur akan otomatis load fungsi dari GitHub dan mulai bekerja

## Catatan Penting

- GUI ini memerlukan HttpService enabled di game Roblox
- Pastikan executor Anda mendukung HttpGet
- Slider settings dapat diatur saat fitur sedang berjalan
- Gunakan delay yang sesuai untuk menghindari detection
- Window position dan size bisa disesuaikan sesuai keinginan

## Credits

Created by Habibihidayat42
Repository: https://github.com/Habibihidayat42/keaby

## License

Free to use and modify
