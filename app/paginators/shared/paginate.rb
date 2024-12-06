# frozen_string_literal: true

module Shared
  class Paginate
    include Pagy::Backend
    include Pundit::Authorization

    def initialize(collection, params, current_user)
      @current_user = current_user
      @collection = collection
      @page = params[:page] || Pagy::DEFAULT[:page]

      per_page_limit = Pagy::DEFAULT[:items]

      @limit = if params[:per_page].to_i.between?(1, per_page_limit)
                  params[:per_page].to_i
      else
                  per_page_limit
      end
    end

    def call
      pagy, records = pagy(policy_scope(collection), page:, limit:)
      { pagy:, records: }
    end

    private

    attr_reader :collection, :page, :limit, :current_user
  end
end
