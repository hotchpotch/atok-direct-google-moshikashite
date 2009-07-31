#! /usr/bin/ruby -Ku

require 'uri'
require 'open-uri'
require 'nkf'
$KCODE = 'u'

module Atok_plugin
  def run_process( a_request_data )
    word = a_request_data[ 'composition_string' ]
    res = []
    if m = GoogleMoshikashite.new.moshikashite(word)
      res << { 'hyoki' => m }
    end
    { 'candidate' => res }
  end
end


class GoogleMoshikashite
  def source(word)
    source = open("http://www.google.co.jp/search?hl=ja&q=#{URI::encode(word)}&lr=lang_ja") do |f|
      if f.charset == 'shift_jis'
        NKF.nkf('-w', f.read)
      else
        f.read
      end
    end
  end

  def moshikashite(word)
    if m = source(word).match(%r{もしかして.+class=spell><b>([^<]+)</b>})
       m[1]
    end
  end
end

if $0 == __FILE__
  def is(a, b)
    if a == b
      puts "#{a} is #{b}"
    else
      raise "#{a} is not #{b}"
    end
  end
  g = GoogleMoshikashite.new
  is g.moshikashite('さいとうちわ'), '斎藤千和'
  is g.moshikashite('牧野由衣'), '牧野由依'
  is g.moshikashite('小島真由美'), '小島麻由美'
end

