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

  class User < Sequel::Model(:wp_users)
    set_dataset from(:wp_users).reverse_order(:ID)

    include Importable

    def import
      if user_email.present?
        record = ::User.find_or_initialize_by_email(user_email)
      else
        if fbconnect_userid != '0'
          fb_id = fbconnect_userid
        else
          fb_id = user_login.split('_')[1]
        end
        record = ::User.find_or_initialize_by_fb_userid(fbconnect_userid)
        record.email = "invalid-#{pk}@example.com"
      end
      unless record.persisted?
        generated_password = Devise.friendly_token.first(10)
        record.password              = generated_password
        record.password_confirmation = generated_password
        record.id           = pk
        record.fb_userid    = fbconnect_userid.to_i == 0 ? nil : fbconnect_userid
        record.alias        = user_login.match(/^fb_/i) ? display_name : user_login
        record.karma        = 0
        record.created_at   = user_registered
        record.updated_at   = user_registered
        record.confirmed_at = user_registered
        unless record.valid?
          record.alias = record.alias + '-0'
        end
        record.save!
      end
    end
  end

  class Comment < Sequel::Model(:wp_comments)
    set_dataset from(:wp_comments).filter(:comment_approved => 1)

    include Importable

    def import
      record = ::Comment.find_or_initialize_by_id(pk)
      unless record.persisted?
        record.id         = pk
        record.user_id    = user_id.to_i > 0 ? user_id.to_i : find_author(comment_author_email)
        record.post_id    = comment_post_ID
        record.author     = comment_author
        record.author_email  = comment_author_email
        record.gravatar_hash = Digest::MD5.hexdigest(comment_author_email.strip.downcase)
        record.author_ip  = comment_author_IP
        record.content    = comment_content
        record.created_at = comment_date
        record.status     = 'approved'
        record.save!
      end
    end

    def find_author(email)
      @@authors ||= {}
      unless @@authors.include? email
        user = ::User.find_by_email email
        @@authors[email] = user.id if user
      end
      @@authors[email]
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
    User.import
    Meta.import
    Comment.import
  end

end
