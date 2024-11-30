# frozen_string_literal: true

class Base < ApplicationRecord
  include Crm::RansackableAttributes

  self.abstract_class = true

  attribute :use_custom_serializer, :boolean, default: false

  def self.belongs_to_required_by_default
    false
  end

  def self.base_scopes
    where(nil)
  end

  def self.base_uniqueness_scope
    ApplicationRecord.try(:base_uniqueness_scope) || []
  end

  # FIXME: https://github.com/rails/rails/issues/40943
  def self.has_many_inversing
    false
  end

  def self.json_api_columns
    column_names.reject { |c| c.match(/(?<![a-zA-Z])id$|preferences|(.*)password|(.*)token|(.*)api_key/) } + custom_column_names
  end

  def self.json_api_permitted_attributes
    skipped_attributes = %w[id]

    column_names.reject { |c| skipped_attributes.include?(c.to_s) }
  end

  def self.json_api_type
    to_s.demodulize.underscore
  end

  def self.custom_column_names
    []
  end

  def self.exportable_columns
    column_names
  end
end
