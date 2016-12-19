#!/usr/bin/env ruby

require 'csv'

atts  = CSV.table('wiflower(attributes).txt', col_sep: ';')
data  = CSV.table('wiflower(data).txt'      , col_sep: ';')
items = CSV.table('wiflower(items).txt'     , col_sep: ';')

att_hash = {}
atts.each do |att|
  parts = att[:attname].split(' / ').map(&:strip)
  att_hash[att[:attid]] = {
    column: parts[0..-2].join(' / '),
    value: parts[-1],
  }
end
all_columns = att_hash.values.map { |v| v[:column] }.uniq.sort

CSV.open('output.csv', 'wb') do |csv|
  csv << [
    'name',
    'genus',
    'species',
    'family',
    *all_columns,
  ]
  items.each do |item|
    obj = {}
    data.each do |d|
      if d[:itemid] == item[:itemid]
        att = att_hash[d[:attid]]
        if obj.has_key? att[:column]
          obj[att[:column]] += ';' + att[:value] # TODO determine real separator
        else
          obj[att[:column]] = att[:value]
        end
      end
    end
    csv << [
      item[:commonname],
      item[:genus],
      item[:species],
      item[:family],
      *(all_columns.map { |col| obj[col] }),
    ]
  end
end
