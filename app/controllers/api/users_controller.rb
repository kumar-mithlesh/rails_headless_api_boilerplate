module Api
  class UsersController < ResourceController
    private
    def model_class
      User
    end
  end
end
