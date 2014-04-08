require_dependency "lti_box_engine/application_controller"

module LtiBoxEngine
  class AccountsController < ApplicationController
    http_basic_authenticate_with name: BOX_CONFIG[:admin_username], password: BOX_CONFIG[:admin_password]

    def index
      @accounts = Account.all
      respond_to do |format|
        format.html { render layout: 'lti_box_engine/accounts' }
        format.json { render :json => { accounts: @accounts.as_json }}
      end
    end

    def create
      account = Account.by_auth(account_params[:oauth_key], account_params[:oauth_secret]).first
      if account
        render text: "Account already exists with key and secret", status: 400
      else
        account = Account.new(account_params)
        if account.save
          render json: { account: account }
        else
          render json: { errors: account.errors.full_messages }, status: 422
        end
      end
    end

    def update
      account = Account.where(id: params[:id]).first
      if account.update_attributes(account_params)
        render json: { account: account }
      else
        render json: { errors: account.errors.full_messages }, status: 422
      end
    end

    def destroy
      account = Account.where(id: params[:id]).first
      if account
        account.destroy
      end
      render text: "OK", status: 200
    end

    private

    def account_params
      params.require(:account).permit(:name, :oauth_key, :oauth_secret)
    end
  end
end
