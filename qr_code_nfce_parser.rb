require 'nokogiri'
require 'sequel'
require 'pg'

@page = Nokogiri::HTML(open("QRCodeLinkNFCE.html"))

@trs = @page.css('table#tbItensList tr')

def rows
  @trs[1..-1].map do |row|
    row = row.text.split("\n")
    {
      item_number: row[2].strip,
      desc: row[3].strip,
      qnty: row[4].strip,
      unid: row[5].strip,
      vl_unid: row[6].strip,
      vl_total: row[7].strip,
    }
  end
end

# Entities

class Product
end
