def tebak_angka
  rahasia = rand(1..100)
  percobaan = 0

  puts "=== Game Tebak Angka ==="
  puts "Tebak angka antara 1 sampai 100!"

  loop do
    print "Tebakanmu: "
    tebakan = gets.chomp.to_i
    percobaan += 1

    if tebakan < rahasia
      puts "Terlalu kecil!"
    elsif tebakan > rahasia
      puts "Terlalu besar!"
    else
      puts "Benar! Angkanya adalah #{rahasia}"
      puts "Kamu berhasil dalam #{percobaan} percobaan."
      break
    end
  end
end

tebak_angka