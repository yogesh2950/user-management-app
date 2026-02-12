class CreateUser
    # helps to initialize object
    def initialize()
    end

    def call(user_params)
        pp user_params
        @user = User.new( user_params )
        pp @user
        if @user.save
            { success: true, user: @user }
        else
            { success: false, user: @user }
        end
    end
end