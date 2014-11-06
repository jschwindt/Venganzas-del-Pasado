ThinkingSphinx::Index.define :comment, :with => :active_record do
  # fields
  indexes content
  indexex author

  # attributes
  has created_at

  where "status IN ('neutral', 'approved', 'flagged')"

end

