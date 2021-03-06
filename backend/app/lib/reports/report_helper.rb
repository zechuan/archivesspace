require_relative 'csv_response'
require_relative 'json_response'
require_relative 'xlsx_response'
require_relative 'pdf_response'

module ReportHelper

  ALLOWED_REPORT_FORMATS = ["json", "csv", "xlsx", "html", "pdf"]

  def self.allowed_report_formats
    ALLOWED_REPORT_FORMATS
  end


  def self.report_formats
    ["format",
     String,
     "The format to render the report (one of: #{ALLOWED_REPORT_FORMATS.join(", ")})",
     :validation => ["Must be one of #{ALLOWED_REPORT_FORMATS.join(", ")}",
                     ->(v){ ALLOWED_REPORT_FORMATS.include?(v) }]]
  end



  module ResponseHelpers
    def report_response(report, format)
      @base_url = request.base_url

      if format == "csv"
        [200, {"Content-Type" => "text/plain; charset=UTF-8", "Content-Disposition" => "attachment; filename=\"#{report.class.name}.csv\""}, CSVResponse.new(report)]
      elsif format == "xlsx"
        [200, {"Content-Type" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Content-Disposition" => "attachment; filename=\"#{report.class.name}.xlsx\""}, XLSXResponse.new(report).to_stream]
      elsif format == "html"
        [200, {"Content-Type" => "text/html", "Content-Disposition" => "attachment; filename=\"#{report.class.name}.html\""}, erb(:'reports/report', :locals => {:report => report})]
      elsif format == "pdf"
        [
          200,
          {"Content-Type" => "application/pdf", "Content-Disposition" => "attachment; filename=\"#{report.class.name}.pdf\""},
          PDFResponse.new(report, erb(:'reports/report', :locals => {:report => report}),  @base_url).generate
        ]
      else
        # default to json
        [200, {"Content-Type" => "application/json; charset=UTF-8", "Content-Disposition" => "attachment; filename=\"#{report.class.name}.json\""}, JSONResponse.new(report)]
      end
    end
  end
end
