### Tugas 7

1. Widget tree adalah susunan widget berbentuk hierarki yang membentuk tampilan aplikasi. Parent menampung dan mengatur child melalui properti seperti `child` atau `children`. Contohnya, `Column` menjadi parent yang menyusun beberapa `InfoCard` secara vertikal, sedangkan setiap `InfoCard` membangun tampilan berisi teks identitas.

2. Widget yang digunakan adalah `MyApp` untuk konfigurasi aplikasi, `MyHomePage` untuk halaman utama, `InfoCard` untuk kartu identitas, dan `ItemCard` untuk kartu aksi. `MaterialApp` mengatur tema dan halaman awal; `Scaffold` menyediakan kerangka halaman; `AppBar` menampilkan bilah judul; `Text` menampilkan tulisan; dan `Icon` menampilkan ikon. `SafeArea` menghindari area sistem; `SingleChildScrollView` memungkinkan halaman digulir; `Center` memusatkan konten; `ConstrainedBox` membatasi ukuran; dan `LayoutBuilder` menyesuaikan layout berdasarkan ruang yang tersedia. `Column` menyusun widget vertikal, `Row` menyusunnya horizontal, `Expanded` membagi ruang, `SizedBox` memberi jarak, dan `GridView.count` menyusun kisi tombol. `Card` membuat kartu berbayang; `Padding` memberi ruang di sekeliling child; `Container` membungkus konten dan memberi padding; `Material` menyediakan permukaan berwarna dan efek tinta; `InkWell` menangani ketukan; dan `SnackBar` menampilkan pesan sementara. Kode juga mengakses `Theme` untuk membaca tema dan `ScaffoldMessenger` untuk mengelola SnackBar.

3. `MaterialApp` menyediakan konfigurasi aplikasi Material, seperti judul, tema, halaman awal, dan navigasi. Widget ini biasanya diletakkan dekat akar widget tree agar konfigurasi tersebut dapat digunakan oleh halaman di bawahnya. Pada proyek ini, `MyApp` membangun `MaterialApp` dengan tema indigo dan `MyHomePage` sebagai halaman awal.

4. `StatelessWidget` tidak memiliki objek `State` untuk menyimpan perubahan data lokal, tetapi tetap bisa dibangun ulang ketika konfigurasi atau dependensinya berubah. `StatefulWidget` memiliki objek `State` untuk menyimpan data yang berubah dan dapat meminta rebuild melalui `setState`. Gunakan `StatelessWidget` untuk profil dan menu seperti pada proyek ini, sedangkan `StatefulWidget` cocok untuk penghitung atau formulir yang mengelola perubahan data lokal.

5. `BuildContext` mewakili posisi widget dalam widget tree. Konteks diperlukan untuk mengakses ancestor dan konfigurasi yang tersedia pada posisi tersebut. Dalam `build(BuildContext context)`, proyek menggunakan `Theme.of(context)` untuk membaca warna tema dan `ScaffoldMessenger.of(context)` untuk mengelola SnackBar ketika kartu ditekan. Konteks harus berada di bawah widget penyedia yang ingin diakses.

6. Hot reload menerapkan perubahan kode sambil mempertahankan state, sehingga cocok untuk perubahan teks, warna, atau layout. Hot reload tidak menjalankan ulang `main()` dan `initState()`. Hot restart memulai ulang aplikasi Flutter, menghapus state yang sedang berjalan, dan menjalankan inisialisasi kembali. Hot restart diperlukan untuk perubahan inisialisasi atau struktur tipe yang tidak didukung hot reload. Full restart menghentikan lalu menjalankan kembali aplikasi beserta proses build bagian platform, misalnya setelah perubahan kode Kotlin, Swift, atau plugin yang mengubah bagian native.

### Tugas 8

1. `Navigator.push()` menambahkan rute baru di atas rute aktif, sehingga halaman sebelumnya masih bisa dibuka kembali. `Navigator.pushReplacement()` mengganti rute aktif dengan rute baru. `Navigator.pop()` menutup rute teratas untuk kembali ke rute di bawahnya. Kartu **Tambah Pendidikan** memakai `push()`. Saat **Home** dipilih dari drawer, drawer ditutup terlebih dahulu. Jika Home masih ada di tumpukan, `pop()` menutup formulir; jika formulir sebelumnya menggantikan Home, `pushReplacement()` membuka Home kembali.

2. `Scaffold` menyediakan tempat untuk `AppBar`, `drawer`, dan `body` pada setiap halaman. `AppBar` menampilkan judul dan tombol menu, sementara `LeftDrawer` yang sama menyediakan tujuan navigasi di halaman utama dan kedua formulir. App bar halaman utama dan formulir pendidikan sama-sama mengambil warna latar dari `colorScheme.primary` dan warna judul serta ikon dari `colorScheme.onPrimary`.

3. Formulir pendidikan memakai `Column` supaya input dan tombol **Simpan** tersusun vertikal di layar sempit. Padding 16 piksel logis memberi ruang di tepi layar dan `SizedBox` memberi jarak antarinput. `SingleChildScrollView` membuat bagian bawah, termasuk tombol **Simpan**, tetap bisa dijangkau ketika tinggi layar berkurang saat papan ketik muncul.

4. `GlobalKey<FormState>` memberi tombol **Simpan** akses ke state formulir. `validate()` menjalankan `validator` pada setiap kolom dan menampilkan pesan di kolom yang belum valid. Dialog baru muncul jika semua kolom lolos. Contohnya, tahun selesai `2023` ditolak jika tahun mulai `2024`. Papan ketik angka membantu pengguna memasukkan tahun, tetapi tidak bisa memastikan format empat digit atau memeriksa urutan kedua tahun.

### AI Disclosure
--