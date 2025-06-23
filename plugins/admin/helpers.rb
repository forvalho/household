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

      def render_sidebar
        erb :_sidebar, layout: false, views: settings.plugin_views_path
      end

      def add_admin_nav_links
        @nav_links ||= []
        if admin_logged_in?
          @nav_links << { type: :button, text: 'Admin', href: '/admin/dashboard', icon: 'fa-user-shield' }
          @nav_links << { type: :icon, href: '/admin/logout', icon: 'fa-sign-out-alt', title: 'Logout Admin' }
        end
      end
    end
  end
end
