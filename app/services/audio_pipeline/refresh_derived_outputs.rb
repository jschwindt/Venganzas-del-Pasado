module AudioPipeline
  class RefreshDerivedOutputs
    class << self
      def call(post)
        return unless Rails.application.config.x.refresh_audio_pipeline_outputs

        post.index!
        Rails.application.load_tasks
        task = Rake::Task["sitemap:refresh:no_ping"]
        task.reenable
        task.invoke
      end
    end
  end
end
