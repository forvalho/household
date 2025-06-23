module Household
  module Admin
    module Helpers
      def admin_logged_in?
        session[:admin_id].present?
      end

      def current_admin
        @current_admin ||= ::Admin.find(session[:admin_id]) if session[:admin_id]
      end

      def require_admin_login
        redirect '/admin/login' unless admin_logged_in?
      end
    end
  end
end
