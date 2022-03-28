class ReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_authorizer
    before_action :set_printing_reports, only: [:download_experience, :download_report]
    def index
        @credentials = @authorizer.get_credentials @user_id
        if @credentials.blank?
            if params[:code].present? && params[:code].size > 50 
                    @credentials = @authorizer.get_and_store_credentials_from_code(
                        user_id: @user_id, code: params[:code], base_url: ENV['OOB_URI'])
            end
        end
        if @credentials.present?
            redirect_to connect_google_sheets_path if @credentials.expires_at < Time.now
            service = Google::Apis::SheetsV4::SheetsService.new
            service.client_options.application_name = ENV['APPLICATION_NAME']
            service.authorization = @credentials
            range = "Copy of Master!A2:Z"
            response = service.get_spreadsheet_values ENV['spreadsheet_id'], range
            @@reports = []
            @found_tags = []
            response.values.each do |row|
                row[1].to_s.split(/[,;\s]/).each {|tag| @found_tags << tag unless tag.in?(@found_tags)}
                report = Report.new(row[1], row[0], row[4], row[3], row[9], row[21], row[10] ,row[11] ,row[13] ,row[12] ,row[15] ,row[14] ,row[7] ,row[5] ,row[6], row[8])
                @@reports << report
            end
        end
    end
    def connect_google_sheets
        credentials = @authorizer.get_credentials @user_id
        if credentials.nil?       
            url = @authorizer.get_authorization_url base_url: ENV['OOB_URI']
            redirect_to url
        elsif credentials.present? && credentials.expires_at < Time.now
            tokens = YAML.load_file(ENV["TOKEN_PATH"])
            tokens.delete('default')
            File.open(ENV["TOKEN_PATH"], "w"){|f| YAML.dump(tokens, f)}
            url = @authorizer.get_authorization_url base_url: ENV['OOB_URI']
            redirect_to url
        else
            redirect_to root_path
        end
    end
    #a b c d e f g h i j k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  Z
    #0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
    def download_experience
        
    end

    def download_report
        @first_page = true
        if params[:download_type] == 'reports'
            respond_to do |format|
                format.pdf do
                    @pdf = render_to_string(
                    pdf: "file_name.pdf",
                    template: "reports/show.html.erb",
                    #locals:  {report: @@reports.first},
                    layout: 'pdf.html.erb',
                    page_size: 'Letter',
                    # header: {html: {template: 'reports/_header'}},
                    footer: {html: {template: 'reports/_footer'}},
                    show_as_html: true,
                    margin:  {  top:               0,                     # default 10 (mm)
                                left:              0,
                                right:             0})
    
                    send_data(@pdf, filename: "projects_report.pdf")
                end
                format.html do 
                    render "reports/show.html.erb"
                end
            end
        elsif params[:download_type] == 'experience'
            respond_to do |format|
                format.pdf do
                    @pdf = render_to_string(
                    pdf: "file_name.pdf",
                    template: "reports/experience.html.erb",
                    #locals:  {report: @@reports.first},
                    layout: 'pdf.html.erb',
                    page_size: 'A4',
                    orientation: 'Landscape',
                    header: {html: {template: 'reports/_header'}},
                    footer: {html: {template: 'reports/_footer'}},
                    show_as_html: true,
                    margin:  {  top:               82,         # default 10 (mm)
                                left:              0,#16,
                                right:            0})#20})
    
                    send_data(@pdf, filename: "previous_project_experiences.pdf")
                end
                format.html do 
                    render "reports/show.html.erb"
                end
            end
        end
    end

    private
    def set_authorizer
        scope = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
        client_id = Google::Auth::ClientId.from_file ENV['CREDENTIALS_PATH']
        token_store = Google::Auth::Stores::FileTokenStore.new file: ENV['TOKEN_PATH']
        @authorizer = Google::Auth::UserAuthorizer.new client_id, scope, token_store
        @user_id = "default"
    end
    def set_printing_reports
        tags = params[:tags]
        @printing_reports = []
        @@reports.each do |report|
            report_tags = report.get_tags
            report_tags.each do |report_tag|
                if report_tag.in?(tags)
                    @printing_reports << report
                    break
                end
            end
        end
    end
end
