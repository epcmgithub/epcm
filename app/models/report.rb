class Report
    def initialize(tags = "" ,project_no = "",project_name = "",client = "",region_location = "",client_contact_details = "",start_date = "",end_date = "",project_value_us = "",project_value_zar = "",contract_value_us = "",contract_value_zar = "",summary = "",description = "",scope_of_services = "")
        @project_name =project_name
        @client =client
        @region_location = region_location
        @client_contact_details = client_contact_details
        @start_date = start_date 
        @end_date = end_date
        @project_value_us = project_value_us
        @project_value_zar = project_value_zar
        @contract_value_us = contract_value_us
        @contract_value_zar = contract_value_zar
        @summary = summary
        @description = description
        @scope_of_services = scope_of_services
        @project_no = project_no
        @tags = tags
    end

    def get_tags
        @tags.present? ? @tags.split(/[.;\s]/) : []
    end

    attr_reader :tags, :project_no ,:project_name ,:client ,:region_location ,:client_contact_details ,:start_date ,:end_date ,:project_value_us ,:project_value_zar ,:contract_value_us ,:contract_value_zar ,:summary ,:description ,:scope_of_services
end