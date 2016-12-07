class Api::V1::ReportCommentsController < Api::V1::ApiProtectedController
  @@limit = 10

  def index
    per_page = (params[:per_page] || @@limit).to_i
    page     = (params[:page] || 1).to_i

    reports      = Report.where(reportable_type: 'PostComment').group(:reportable_id)
    reports      = reports.page(page.to_i).per_page(per_page.to_i)
    resp_data    = report_comments_response(reports)
    paging_data  = get_paging_data(page, per_page, reports)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''


    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end

  def show
    report       = Report.find_by_id(params[:id])
    comment      = report.reportable
    resp_data    = comment.post_comment_response
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def destroy
    report             = Report.find_by_reportable_id(params[:id])
    comment            = report.reportable
    comment.is_deleted =true
    comment.save!
    report.destroy!
    resp_data    = ''
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def remove_comment_from_report
    report = Report.find_by_reportable_id(params[:id])
    report.destroy!
    report.save!
    resp_data    = ''
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def report_comments_response(reports)
    reports = reports.as_json(
        only: [:id, :reportable_type, :reportable_id, :member_profile_id, :comment],
    )
    { reports: reports }.as_json
  end
end
