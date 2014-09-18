class User < ActiveRecord::Base
    belongs_to :referrer, :class_name => "User", :foreign_key => "referrer_id"
    has_many :referrals, :class_name => "User", :foreign_key => "referrer_id"
    
    attr_accessible :email

    validates :email, :uniqueness => true, :format => { :with => /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i, :message => "Invalid email format." }
    validates :referral_code, :uniqueness => true

    before_create :create_referral_code
    after_create :send_welcome_email

    REFERRAL_STEPS = [
        {
            'count' => 5,
            "html" => "Pot of<br>Lube",
            "class" => "two",
            "image" =>  ActionController::Base.helpers.asset_path("http://cdn.shopify.com/s/files/1/0258/9827/products/photo_2_11_large.jpg?v=1382999292")
        },
        {
            'count' => 10,
            "html" => "OM Essentials<br><span>for FREE</span>",
            "class" => "three",
            "image" => ActionController::Base.helpers.asset_path("http://onetaste.us/wp-content/uploads/2014/09/ipad2.jpg")
        },
        {
            'count' => 25,
            "html" => "OM Essentials &<br>OM Nest",
            "class" => "four",
            "image" => ActionController::Base.helpers.asset_path("http://onetaste.us/wp-content/uploads/2014/09/omessentials-nest1.jpg")
        },
        {
            'count' => 50,
            "html" => "Lifetime of Lube<br>& FREE OM Class",
            "class" => "five",
            "image" => ActionController::Base.helpers.asset_path("http://onetaste.us/wp-content/uploads/2014/09/lube-class1.jpg")
        }
    ]

    private

    def create_referral_code
        referral_code = SecureRandom.hex(5)
        @collision = User.find_by_referral_code(referral_code)

        while !@collision.nil?
            referral_code = SecureRandom.hex(5)
            @collision = User.find_by_referral_code(referral_code)
        end

        self.referral_code = referral_code
    end

    def send_welcome_email
        UserMailer.delay.signup_email(self)
    end
end
