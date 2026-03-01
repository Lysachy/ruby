def kalkulator
  puts "=== Kalkulator Sederhana ==="
  print "Masukkan angka pertama: "
  a = gets.chomp.to_f

  print "Masukkan operator (+, -, *, /): "
  op = gets.chomp

  print "Masukkan angka kedua: "
  b = gets.chomp.to_f

  hasil = case op
          when "+" then a + b
          when "-" then a - b
          when "*" then a * b
          when "/" then b != 0 ? a / b : "Error: Tidak bisa dibagi 0"
          else "Operator tidak valid"
          end

  puts "Hasil: #{a} #{op} #{b} = #{hasil}"
end

kalkulator