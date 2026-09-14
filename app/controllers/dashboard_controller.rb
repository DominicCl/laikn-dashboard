require "google/cloud/firestore"

class DashboardController < ApplicationController
  def index
    # Grab the user ID from the URL (passed by the VS Code extension)
    @user_id = params[:user]
    
    # If no user is provided, default to an empty state
    if @user_id.blank?
      @analysis_count = 0
      @immediate_count = 0
      @shifted_count = 0
      @decisions = []
      return
    end

    # Initialize Firestore
    firestore = Google::Cloud::Firestore.new(project_id: "loyal-theater-484704-g3")

    # Count routing analyses; no workload energy is measured, so CO2 savings are unknown.
    history_docs = firestore.col("history").where("user_id", "=", @user_id).get
    @requests = history_docs
    @analysis_count = history_docs.count

    # 2. Process User Decisions (from the 'decisions' collection)
    # Ordering by timestamp descending puts the newest actions at the top of the feed
    decision_docs = firestore.col("decisions")
                             .where("user_id", "=", @user_id)
                             .order("timestamp", :desc)
                             .get

    @immediate_count = 0
    @shifted_count = 0
    @decisions = []

    decision_docs.each do |doc|
      data = doc.data
      type = data[:decision] # 'immediate', 'shifted', 'shift_completed', or 'ignored'
      
      # Tally the metrics
      if type == 'immediate'
        @immediate_count += 1
      elsif type == 'shifted' || type == 'shift_completed'
        @shifted_count += 1
      end
      
      # Build the array for the Activity Feed table
      @decisions << {
        timestamp: data[:timestamp] || Time.now,
        decision_type: type,
        chosen_option: data[:chosen_option]
      }
    end
  end
end
