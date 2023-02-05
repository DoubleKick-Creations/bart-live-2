class Station < ApplicationRecord
  validates :abbr, presence: true

  BART_API_KEY = Rails.application.credentials.bart_api_key

  def fetch_bart_data
    bart_query_uri = Addressable::URI.new(
      scheme: 'http',
      host: 'api.bart.gov',
      path: 'api/etd.aspx',
        query_values: {
          cmd: 'etd',
          orig: abbr,
          key: BART_API_KEY
        })
    response = HTTParty.get(bart_query_uri)
  end

  def format_station_data
    if after_service_hours?
      response['root']['message'] = 'No trains at this time.' 
      return response
    end

    if api_updates_down?
      response['root']['message'] = 'Bart is not providing updates at this time.' 
      return response
    end
        
    if one_train?
      response['root']['station']['etd'] = [response['root']['station']['etd']]
    end

    get_train_lines.each do |line|
      line['estimate'] = [line['estimate']] unless line['estimate'].is_a?(Array)
    end
    response
  end

  private
    
  def after_service_hours?
    response['root']['message'].present?
  end

  def api_updates_down?
    response['root']['station']['message'] && response['root']['station']['message']['error'] == 'Updates are temporarily unavailable.'
  end

  def two_or_more_trains? 
    response['root']['station']['etd'].is_a?(Array)
  end

  # BART API sends multiple trains per line in an array, but does not for a single train
  # single trains need to be wrapped in arrays to prevent view parsing from breakin
  def one_train?
    !two_or_more_trains?
  end

  def get_train_lines
    response['root']['station']['etd']
  end
end
  
