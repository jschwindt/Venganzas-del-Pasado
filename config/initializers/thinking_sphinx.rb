ThinkingSphinx::Middlewares::DEFAULT.insert_after(
  ThinkingSphinx::Middlewares::Inquirer, ThinkingSphinx::Middlewares::UTF8
)
ThinkingSphinx::Middlewares::RAW_ONLY.insert_after(
  ThinkingSphinx::Middlewares::Inquirer, ThinkingSphinx::Middlewares::UTF8
)
ThinkingSphinx::SphinxQL.variables!

