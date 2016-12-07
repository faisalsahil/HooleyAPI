class Api::V1::ReportPostsController < Api::V1::ApiProtectedController

  # def index
  #   reports      = Report.where(reportable_type: 'Post').group(:reportable_id)
  #   resp_data    = reports_post_response(reports)
  #   resp_status  = 1
  #   resp_message = 'Success'
  #   resp_errors  = ''
  #   common_api_response(resp_data, resp_status, resp_message, resp_errors)
  # end

  def show
    report       = Report.find_by_id(params[:id])
    post         = report.reportable
    reports      = Report.where(reportable_id: report.reportable_id)
    resp_data    = Report.report_post_response(reports, post)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)

  end

  def destroy
    report          = Report.find_by_reportable_id(params[:id])
    post            = report.reportable
    post.is_deleted =true
    post.save!
    report.destroy!
    resp_data    = ''
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)


  end

  def remove_post_from_report
    report          = Report.find_by_reportable_id(params[:id])
    report.destroy!
    report.save!
    resp_data    = ''
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end


  def reports_post_response(reports)
    reports = reports.as_json(
        only: [:id, :reportable_type, :reportable_id, :member_profile_id, :comment],
    )
    { reports: reports }.as_json
  end
end
