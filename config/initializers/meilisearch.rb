MeiliSearch::Rails.configuration = {
  meilisearch_url: ENV.fetch("MEILISEARCH_HOST", "http://localhost:7700"),
  meilisearch_api_key: ENV["MEILISEARCH_API_KEY"].presence,
  pagination_backend: :kaminari,
  timeout: 3,
  max_retries: 2
}
