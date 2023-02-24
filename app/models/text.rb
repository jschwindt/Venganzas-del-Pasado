class Text < ApplicationRecord
  include MeiliSearch::Rails
  belongs_to :audio

  def search_data
    {
      text: text,
      created_at: audio.post.created_at
    }
  end

  def timestamp
    audio.post.created_at.to_i
  end

  meilisearch force_utf8_encoding: true do
    attribute :text, :timestamp
    filterable_attributes [:timestamp]
    sortable_attributes [:timestamp]
    ranking_rules [
      "sort",
      "exactness",
      "words",
      "typo",
      "proximity",
      "attribute",
    ]

    # The following parameters are applied when calling the search() method:
    attributes_to_highlight ['text']
    pagination max_total_hits: 1000
  end

end
