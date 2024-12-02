# frozen_string_literal: true

module Api
  module Caching
    extend ActiveSupport::Concern

    def collection_cache_key(collection)
      max_updated_at = collection.maximum(:updated_at)
      ids            = collection.unscope(:includes).unscope(:order).pluck(:id)

      cache_key_parts = [
        self.class.to_s,
        max_updated_at,
        associated_max_updated_at,
        ids,
        resource_includes,
        sparse_fields,
        serializer_params,
        params.dig(:filter, :s)&.strip,
        params[:page]&.to_s&.strip,
        params[:per_page]&.to_s&.strip
      ].flatten.join("-")

      Digest::MD5.hexdigest(cache_key_parts)
    end

    def collection_cache_opts
      {
        namespace: "api_v2_collection_cache",
        expires_in: 3600
      }
    end

    def associated_max_updated_at
      return unless params[:include].present?

      model_klasses = params[:include].split(",").map do |name|
        name.singularize.camelize.safe_constantize
      end.compact

      model_klasses.map do |klass|
        klass.maximum(:updated_at)
      end.compact.max
    end
  end
end
