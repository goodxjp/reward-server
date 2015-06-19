namespace :point do
  desc "Add bonus point to all users"
  task :add_all => :environment do
    ActiveRecord::Base.transaction do
      MediaUser.all.each do |media_user|
        media_user.lock!
        Point.add_point(media_user, PointType::MANUAL, 100, "秘密のポイント")
      end
    end
  end
end
