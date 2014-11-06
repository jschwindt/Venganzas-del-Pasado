ThinkingSphinx::Index.define :post, :with => :active_record do
  # fields
  indexes title
  indexes content

  # attributes
  has created_at

  where "status = 'published'"

end
