module Wordpress
  module Importable
    module ClassMethods

      def import
        puts "Importando #{name}"
        each do |record|
          begin
            record.import
          rescue => e
            $stderr.puts "#{name}(#{record.pk.inspect}): #{e}"
          end
        end
      end
    end

    module InstanceMethods
      def import
        raise NotImplementedError
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
      klass.send :include, InstanceMethods
    end
  end

  class Post < Sequel::Model(:wp_posts)
    set_dataset from(:wp_posts).filter(:post_status => 'publish')
#    one_to_many :comments, :key => :comment_post_ID

    include Importable

    def import
      record = ::Post.find_or_initialize_by_id(pk)
      record.id         = pk
      record.title      = post_title
      record.content    = post_content
      record.created_at = post_date
      record.updated_at = post_modified
      record.status     = 'published'
      record.save!
    end
  end

  class Comment < Sequel::Model(:wp_comments)
    set_dataset from(:wp_comments).filter(:comment_approved => 1)
#    many_to_one :post, :key => :comment_post_ID

    include Importable

    def import
      record = ::Comment.find_or_initialize_by_id(pk)
      record.id         = pk
      record.post_id    = comment_post_ID
      record.author     = comment_author
      record.author_email = comment_author_email
      record.author_url = comment_author_url
      record.author_ip  = comment_author_IP
      record.content    = comment_content
      record.created_at = comment_date
      record.status     = 'approved'
      record.save!
    end
  end

  class Meta < Sequel::Model(:wp_postmeta)
    set_dataset from(:wp_postmeta).filter(:meta_key => 'enclosure')

    include Importable

    def import
      record = ::Audio.find_or_initialize_by_post_id(post_id)
      url, bytes, mime = meta_value.split(/\r?\n/)
      record.url   = url
      record.bytes = bytes
      record.save!
    end
  end

  def self.import
    Post.import
    Meta.import
    Comment.import
  end

end
