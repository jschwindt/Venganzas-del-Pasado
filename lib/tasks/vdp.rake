namespace :vdp do
  desc 'Publica contribuciones'
  namespace :contribuciones do
    task publish: :environment do
      Post.waiting.each(&:publish_contribution)
      CarrierWave.clean_cached_files!
    end
  end
end
