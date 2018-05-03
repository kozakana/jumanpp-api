require 'sinatra'
require 'json'
require 'jumanpp_ruby'
require 'yaml'

PARSE_ELEMTS = [
  '表層形', '読み', '見出し語', '品詞大分類', '品詞大分類ID',
  '品詞細分類', '品詞細分類ID', '活用型', '活用型ID', '活用形',
  '活用形ID', '意味情報'
]

config = YAML.load_file('./config.yml')
juman = JumanppRuby::Juman.new(**config)

post '/split', provides: :json do
  content_type :json

  str = params[:string]

  words = juman.parse(str)
  if words.last == 'EOS'
    words = words.slice(0...-1)
  end

  data = {}
  data[:status] = 'success'
  data[:results] = words
  data.to_json
end

post '/parse', provides: :json do
  str = params[:string]

  words = []
  juman.parse(str) do |word|
    words << word
  end

  if words.last == ['EOS']
    words = words.slice(0...-1)
  end

  data = {}
  data[:status] = 'success'
  data[:elements] = PARSE_ELEMTS
  data[:results] = words
  data.to_json
end
