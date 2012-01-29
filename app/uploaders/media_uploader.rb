# encoding: utf-8

class MediaUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "system/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    "/assets/no-image.jpg"
  end

  process :set_content_type

  # Process files as they are uploaded:
  process :resize_to_fit => [2048, 1536]

  # Create different versions of your uploaded files:
  version :thumb, :if => :image? do
    process :resize_to_fit => [200, ""]
  end

  version :large, :if => :image? do
    process :resize_to_fit => [520, ""]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  protected

  def image?(new_file)
    new_file.content_type.try(:include?, 'image')
  end
end
