class Rack::Attack
  REQUEST_LIMIT = 5
  LIMIT_PERIOD = 20.seconds
  PROTECTED_ACTIONS = [
    { controller: 'pull_request_ai/pull_request_ai', action: 'confirm' }
  ]

  def self.protected_route?(path, method)
    route_params = Rails.application.routes.recognize_path(path, method: method)
    PROTECTED_ACTIONS.any? do
      |h| h[:controller] == route_params[:controller] && h[:action] == route_params[:action]
    end

  rescue ActionController::RoutingError
    false
  end

  throttle('open_ai_api_request', limit: REQUEST_LIMIT, period: LIMIT_PERIOD) do |request|
    request.ip if protected_route?(request.path, request.request_method)
  end
end

