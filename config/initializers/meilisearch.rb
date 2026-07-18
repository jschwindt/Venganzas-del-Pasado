MeiliSearch::Rails.configuration = {
  meilisearch_url: ENV.fetch("MEILISEARCH_HOST", "http://localhost:7700"),
  meilisearch_api_key: ENV["MEILISEARCH_API_KEY"].presence || Rails.application.credentials.dig(:meilisearch, :api_key),
  pagination_backend: :kaminari,
  timeout: 3,
  max_retries: 2
}
