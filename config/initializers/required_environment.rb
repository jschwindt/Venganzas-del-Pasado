require Rails.root.join("lib/required_environment")

RequiredEnvironment.validate!(environment: Rails.env)
