class Text < ApplicationRecord
  belongs_to :audio

  def search_data
    {
      text: text,
      created_at: audio.post.created_at
    }
  end

  searchkick searchable: %i[text], filterable: [:created_at], batch_size: 500, settings: {
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
