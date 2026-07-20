require "google/cloud/firestore"

class DashboardController < ApplicationController
  def index
    # 1. Connect
    firestore = Google::Cloud::Firestore.new(project_id: "loyal-theater-484704-g3")
    
    # Extract the user ID from the URL (e.g., ?user=12345)
    target_user_id = params[:user]

    if target_user_id.present?
      # 2. Fetch History (Filtered by user_id, newest first)
      @requests = firestore.col("history")
                           .where("user_id", "=", target_user_id)
                           .order("timestamp", :desc)
                           .limit(50)
                           .get
    else
      # If no user ID is provided, return an empty array to protect data
      @requests = []
    end
    
    # 3. Calculate Total Savings (Only for this specific user)
    @total_saved = 0
    @requests.each do |doc|
      val = doc.data[:co2_saved]
      @total_saved += val.to_i if val 
    end

    # 4. Prepare Chart Data
    chart_data = @requests.to_a.reverse.map do |doc|
      data = doc.data
      {
        time: data[:timestamp].to_time.strftime("%H:%M"), 
        score: data[:carbon_intensity]
      }
    end

    @labels_json = chart_data.map { |d| d[:time] }.to_json
    @values_json = chart_data.map { |d| d[:score] }.to_json
  end
end