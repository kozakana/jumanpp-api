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

def string_param
  if request['HTTP_ACCEPT'] == 'application/json'
    req = request.body.read
    JSON.parse(req)['string']
  else
    params[:string]
  end
end

post '/split', provides: :json do
  content_type :json
  data = {}

  begin
    str = string_param
    raise unless str
  rescue
    data[:status] = 'fail'
    status 400
    return data.to_json
  end

  begin
    words = juman.parse(str)
    if words.last == 'EOS'
      words = words.slice(0...-1)
    end
  rescue
    data[:status] = 'fail'
    status 500
    return data.to_json
  end

  data[:status] = 'success'
  data[:results] = words
  data.to_json
end

post '/parse', provides: :json do
  content_type :json
  data = {}

  begin
    str = string_param
    raise unless str
  rescue
    data[:status] = 'fail'
    status 400
    return data.to_json
  end

  begin
    words = []
    juman.parse(str) do |word|
      words << word
    end

    if words.last == ['EOS']
      words = words.slice(0...-1)
    end
  rescue
    data[:status] = 'fail'
    status 500
    return data.to_json
  end

  data = {}
  data[:status] = 'success'
  data[:elements] = PARSE_ELEMTS
  data[:results] = words
  data.to_json
end

get '/version', provides: :json do
  data = {}
  begin
    data[:results] = JumanppRuby::Juman.version
    data[:status] = 'success'
  rescue
    data[:status] = 'fail'
    status 500
  end
  data.to_json
end
