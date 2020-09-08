class Text < ApplicationRecord
  belongs_to :audio

  searchkick searchable: %i[text], settings: {
    analysis: {
      filter: {
        spanish_stop: {
          type: 'stop',
          stopwords: '_spanish_'
        }
      },
      analyzer: {
        rebuilt_spanish: {
          tokenizer: 'standard',
          filter: %w[asciifolding spanish_stop]
        }
      }
    }
  }

end
