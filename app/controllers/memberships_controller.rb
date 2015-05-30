class MembershipsController < ApplicationController
	before_action :set_membership, only: [:respond]

	load_and_authorize_resource

	# PATCH /memberships/1/respond
	def respond
		if params[:response] == "accept"
			@membership.started_at = DateTime.now
			flash[:alert] = "Could not accept invitation!  #{@membership.errors.full_messages.first}." unless @membership.save
		else
            @membership.destroy ? flash[:notice] = "Denied invitation!" : flash[:alert] = "Could not deny invitation!"
		end

		redirect_to root_path
	end

	private
	def set_membership
		@membership = Membership.find(params[:id])
	end
end
