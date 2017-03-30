class Api::V1::ApiProtectedController < ApplicationController
  # before_action :check_setting_website_required?
  after_action :cors_set_access_control_headers
  before_action :api_restrict_access

  resource_description do
    api_version "All Users - V 1.0"
    app_info "All APIs need Authorization token in HTTP header received in Login response.
        Authorization: Token token=Aj1DzQc06IwaT467V7sq5gZZ"
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin']      = '*'
    headers['Access-Control-Allow-Methods']     = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age']           = '1728000'
    headers['Access-Control-Allow-Credentials'] = 'true'
  end

  unless Rails.application.config.consider_all_requests_local
    # rescue_from CanCan::AccessDenied, with: :exception_response
    # rescue_from Exception, with: :exception_response
  end

  private
  # def check_setting_website_required?
  #   if params.present? && params[:is_setting_websites_required].present?
  #     session[:is_setting_websites_required] = true
  #   else
  #     session[:is_setting_websites_required] = false
  #   end
  # end


  def api_restrict_access_debug
    authenticate_or_request_with_http_token do |token, options|
      user = User.find_by_auth_token(token)
      puts "XXXXXXXXXXXXXXXXXXXXXXXXx"
      puts user.inspect
      puts "XXXXXXXXXXXXXXXXXXXXXXXXx"
      if user.present? #&& user.registered?
        user_session = UserSession.new(user)
        if user_session.save
          true
        else
          false
        end
      else
        false
      end
    end
  end


  def my_logger
    @@my_logger ||= Logger.new("#{Rails.root}/log/my.log")
  end

  def verify_api_auth(request, secret_key)
    begin
      req_header_content_type  = request.headers["Content-Type"]
      req_header_md5           = request.headers["Content-MD5"]
      req_path                 = request.path
      req_header_http_date     = request.headers["HTTP_DATE"]
      req_header_authorization = request.headers["HTTP_AUTHORIZATION"]


      my_logger.info("HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
      my_logger.info(secret_key)
      my_logger.info(req_header_content_type)
      my_logger.info(req_header_md5)
      my_logger.info(req_path)
      my_logger.info(req_header_http_date)
      my_logger.info(req_header_authorization)
      my_logger.info("HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")


      headers              = ApiAuth::Headers.new(request)
      api_canonical_string = headers.canonical_string
      api_canonical_array  = api_canonical_string.split(",")

      api_content_type  = api_canonical_array[0]
      api_md5           = api_canonical_array[1]
      api_path          = api_canonical_array[2]
      api_http_date     = headers.timestamp
      # api_http_date     = "#{api_canonical_array[3]},#{api_canonical_array[4]}"
      api_authorization = headers.authorization_header

      is_request_too_old = Time.httpdate(headers.timestamp).utc < (Time.now.utc - 900)

      my_logger.info("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
      my_logger.info(api_canonical_string)
      my_logger.info(api_content_type)
      my_logger.info(api_md5)
      my_logger.info(api_path)
      my_logger.info(api_http_date)
      my_logger.info(api_authorization)
      my_logger.info(is_request_too_old)
      my_logger.info("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")

    rescue => e
      my_logger.info(e)
    end

  end

  def json_builder(json, status, msg, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}

    info               = ActiveSupport::OrderedHash.new
    info[:resp_status] = status
    info[:message]     = msg
    info[:errors]      = options[:errors]
    info[:paging_data] = options[:paging_data]

    unless (json.to_s == "")
      data = { data: json }
      hash = info.merge(data)
    else
      unless options[:tag_name].blank?
        data = { data: { options[:tag_name] => "" } }.to_hash
      else
        data = { data: "" }.to_hash
      end
      hash = info.merge(data)
    end
    puts hash.to_json
    return hash.to_json
  end


  def common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data=nil)
    render json: json_builder(resp_data, resp_status, resp_message, errors: resp_errors, paging_data: paging_data)
  end

  def api_restrict_access
    unless params[:debug_auth]
      access_id = ApiAuth.access_id(request)

      if access_id.present?
        user_session = UserSession.find_by_auth_token(access_id)
        unless user_session.nil?
          verify_api_auth(request, user_session.auth_token)

          if ApiAuth.authentic?(request, user_session.user.id.to_s)
            # user_session = UserSession.new(user)
            
            if user_session.save
              my_logger.info("SESSION CREATED AND LOGGED IN")
              my_logger.info("")
              my_logger.info("")
              true
            else
              my_logger.info("SESSION NOT CREATED AND LOGGED OUT")
              my_logger.info("")
              my_logger.info("")
              puts "1"*90
              # raise CanCan::AccessDenied
            end
          else
            my_logger.info("API NOT AUTHENTICATED")
            my_logger.info("")
            my_logger.info("")
            puts "2"*90
            # raise CanCan::AccessDenied
          end
        else
          my_logger.info("USER DOES NOT FOUND")
          my_logger.info("")
          my_logger.info("")
          puts "3"*90
          # raise CanCan::AccessDenied
        end
      else
        my_logger.info("ACCESS ID DOES NOT FOUND")
        my_logger.info("")
        my_logger.info("")
        puts "4"*90
        # raise CanCan::AccessDenied
      end
    else
      api_restrict_access_debug
    end
  end


  def exception_response(e)
    resp_data    = ''
    resp_status  = 0
    resp_message = 'Errors'
    resp_errors  = e.message
    respond_to do |format|
      common_api_response(format, resp_data, resp_status, resp_message, resp_errors)
    end
  end

  def get_paging_data(page, per_page, records)
    {
        page:          page,
        per_page:      per_page,
        total_records: records.total_entries,
        total_pages:   records.total_pages
    }
  end
end
