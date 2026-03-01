puts "=== Selamat Datang di Program Biodata Mini ==="

# Menanyakan nama
print "Siapa namamu? "
nama = gets.chomp

# Menanyakan umur dan mengubahnya jadi angka (to_i)
print "Halo #{nama}, umurmu berapa tahun sekarang? "
umur = gets.chomp.to_i 

# Menghitung perkiraan tahun lahir (tahun sekarang 2026)
tahun_lahir = 2026 - umur

# Menampilkan hasil
puts "\n--- Sedang Memproses Data ---"
puts "Ternyata kamu lahir sekitar tahun #{tahun_lahir} ya!"

# Logika pengecekan umur (If/Else)
if umur < 18
  puts "Wah, kamu masih muda banget! Terus semangat belajarnya ya."
elsif umur >= 18 && umur <= 30
  puts "Usia emas nih! Masa-masa produktif, manfaatkan dengan baik."
else
  puts "Keren! Pasti sudah banyak pengalaman hidupnya. Sukses selalu!"
end

puts "=============================================="