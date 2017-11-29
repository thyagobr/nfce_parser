require 'nokogiri'
require 'byebug'
require 'sequel'
require 'sqlite3'

DB = Sequel.sqlite("nfce.db")

DB.create_table? :nfces do
  primary_key :id
  String :number
  String :series
  DateTime :emitted_at
end

DB.create_table? :items do
  primary_key :id
  foreign_key :nfce_id, :nfces
  String :code
  String :description
  Integer :quantity
  String :unity
  Float :value_unit
  Float :value_total
end

nfces = DB[:nfces]
items = DB[:items]

page = Nokogiri::HTML(open("nfce.html"))

nfce_data = page.css('table#tbl-container-nfce-resumida-valida > tbody > tr')[5].css('.NFCCabecalho_SubTitulo')[1].text.strip.split("\n").map { |data| data.strip }

nfce_number = nfce_data[0].split(":")[1].strip
nfce_series = nfce_data[1].split(":")[1].strip
emission_date = nfce_data[2].gsub("Data de Emissão: ", "").split("-")[0].strip
nfce = nfces[{number: nfce_number}]

if nfce
  puts "*** Essa nfce já foi cadastrada"
  exit 1
end

nfce_id = nfces.insert(number: nfce_number, series: nfce_series, emitted_at: Time.parse(emission_date)) 
nfce = nfces[{id: nfce_id}]

puts "[ codigo -- descricao - qtde - un - vl unit - vl total ]"
page.css('table.NFCCabecalho')[3].css('tr')[1..-1].each do |row|
  line = []
  row.css('td').each do |item|
    line << item.text
  end
  puts line.join(" -- ")
  items.insert(nfce_id: nfce[:id],
               code: line[0],
               description: line[1],
               quantity: line[2],
               unity: line[3],
               value_unit: line[4].gsub(',','.').to_f,
               value_total: line[5].gsub(',','.').to_f)
end
puts 'done'
