MeiliSearch::Rails.configuration = {
  meilisearch_url: 'http://localhost:7700',
  meilisearch_api_key: Rails.application.credentials.meilisearch[:api_key],
  pagination_backend: :kaminari,
  timeout: 3,
  max_retries: 2,
}