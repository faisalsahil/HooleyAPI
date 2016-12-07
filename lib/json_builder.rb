module JsonBuilder

  def self.json_builder(json, status, msg, request_id, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}

    info                          = ActiveSupport::OrderedHash.new
    info[:resp_status]            = status
    info[:message]                = msg
    info[:errors]                 = options[:errors]
    info[:paging_data]            = options[:paging_data]
    info[:type]                   = options[:type] if options[:type].present?
    info[:start]                  = options[:start] if options[:start].present?
    info[:next_page_exist]        = options[:next_page_exist] if options[:post_list].present?
    info[:previous_page_exist]    = options[:previous_page_exist] if options[:post_list].present?
    info[:request_id]             = request_id

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

  def self.get_paging_data(page, per_page, records)
    page < records.total_pages  ?  next_page_exist = true : next_page_exist = false
    page > 1 && page <= records.total_pages ?  previous_page_exist = true : previous_page_exist = false
    {
      page:          page,
      per_page:      per_page,
      total_records: records.total_entries,
      total_pages:   records.total_pages,
      next_page_exist: next_page_exist,
      previous_page_exist: previous_page_exist

    }
  end

end