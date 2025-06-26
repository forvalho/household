module AdminHelper
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
    erb :'admin/_sidebar', layout: false
  end

  def redirect_back_or_default(default_path)
    referer = request.referer
    if referer && referer.include?('/admin/')
      redirect referer
    else
      redirect default_path
    end
  end
end
