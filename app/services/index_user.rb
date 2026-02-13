class IndexUser
    def initialize()
    end

    def call(current_user)
        if current_user.role == "admin"
            @users = User.all
            { success: true, user: @users }
        else
            { success: false, user: @user }
        end
    end
end
