todos = []

loop do
  puts "\n=== To-Do List ==="
  puts "1. Lihat daftar"
  puts "2. Tambah tugas"
  puts "3. Hapus tugas"
  puts "4. Keluar"
  print "Pilihan: "

  pilihan = gets.chomp

  case pilihan
  when "1"
    if todos.empty?
      puts "Tidak ada tugas."
    else
      todos.each_with_index { |t, i| puts "#{i + 1}. #{t}" }
    end
  when "2"
    print "Tugas baru: "
    todos << gets.chomp
    puts "Tugas ditambahkan!"
  when "3"
    print "Nomor tugas yang dihapus: "
    idx = gets.chomp.to_i - 1
    if todos[idx]
      puts "\"#{todos.delete_at(idx)}\" dihapus."
    else
      puts "Nomor tidak valid."
    end
  when "4"
    puts "Bye!"
    break
  end
end