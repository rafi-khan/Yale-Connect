require 'mongoid'
require 'ironworker'


# require 'mongo'
# require 'mongoid'

# conn = Mongo::Connection.from_uri("mongodb://admin:admin@ds033097.mongolab.com:33097/campus")
# db = conn["campus"];

class MatcherWorker < IronWorker::Base

    merge "app/models/user.rb"
    merge "app/models/meal.rb"

    def run
        candidates = User.where({"matched" => false, "hiatus" => false}).to_a  # match preferences

        candidates.each do |user|
            candidates.each do |potential|
                continue if user == potential
                continue unless user.preferences.year == potential.year or user.preferences.year.nil?
                continue unless potential.preferences.year == user.year or potential.preferences.year.nil?
                match(user, potential)
                candidates.remove(user)
                candidates.remove(potential)
            end
        end
    end

    def match user1, user2
        m = Meal.new
        m.user_1 = user1
        m.user_2 = user2
        m.save
        # Sendgrid.send
    end

    def init_mongodb
        Mongoid.configure do |config|
            config.database = Mongo::Connection.from_uri("mongodb://admin:admin@ds033097.mongolab.com:33097/campus")
            config.persist_in_safe_mode = false
        end
    end
end