module SearchHelper

  def build_search_params(opts = {})
    search_params = {}

    search_params["filter_term"] = Array(opts["filter_term"] || params["filter_term"]).clone
    search_params["filter_term"].concat(Array(opts["add_filter_term"])) if opts["add_filter_term"]
    search_params["filter_term"] = search_params["filter_term"].reject{|f| Array(opts["remove_filter_term"]).include?(f)} if opts["remove_filter_term"]

    sort = (opts["sort"] || params["sort"])

    # if the browse list was sorted by default
    if sort.nil? && !@search_data.nil? && @search_data.sorted?
      sort = @search_data[:criteria]["sort"]
    end

    if sort
      sort = sort.split(', ')
      sort[1] = opts["sort2"] if opts["sort2"]
      search_params["sort"] = sort.uniq.join(', ')
    end

    if (opts["format"] || params["format"]).blank?
      search_params.delete("format")
    else
      search_params["format"] =  opts["format"] || params["format"]
    end

    search_params["linker"] = opts["linker"] || params["linker"] || false
    search_params["type"] = opts["type"] || params["type"]
    search_params["facets"] = opts["facets"] || params["facets"]
    search_params["exclude"] = opts["exclude"] || params["exclude"]
    search_params["listing_only"] = true if params["listing_only"]
    search_params["include_components"] = opts.has_key?("include_components") ? opts["include_components"] : params["include_components"]

    search_params["q"] = opts["q"] || params["q"]

    search_params.reject{|k,v| k.blank? or v.blank?}
  end


  def allow_multi_select?
    @show_multiselect_column
  end


  def show_record_type?
    !@search_data.single_type? || (@search_data[:criteria].has_key?("type[]") && @search_data[:criteria]["type[]"].include?("agent"))
  end


  # in case the title needs to be handled among other columns
  def no_title!
    @no_title = true
  end


  def show_title_column?
    @search_data.has_titles? && !@no_title
  end


  def title_column_header(title_header)
    @title_column_header = title_header
  end


  def title_column_header_label
    @title_column_header or I18n.t("search_results.result_title")
  end


  def title_sort_label
    @title_column_header or I18n.t("search_sorting.title_sort")
  end


  def can_edit_search_result?(record)
    return user_can?('manage_repository', record['id']) if record['primary_type'] === "repository"
    return user_can?('update_location_record') if record['primary_type'] === "location"
    return user_can?('update_subject_record') if record['primary_type'] === "subject"
    return user_can?('update_classification_record') if ["classification", "classification_term"].include?(record['primary_type'])
    return user_can?('update_agent_record') if Array(record['types']).include?("agent")

    user_can?('update_archival_record')
  end


  def add_column(label, block, opts = {})
    @extra_columns ||= []

    if opts[:sortable] && opts[:sort_by]
      @search_data.sort_fields << opts[:sort_by]
    end

    col = ExtraColumn.new(label, block, opts, @search_data)
    @extra_columns.push(col)
  end


  def extra_columns
    @extra_columns
  end


  def extra_columns?
    return false if @extra_columns == nil

    !@extra_columns.empty?
  end


  class ExtraColumn

    def initialize(label, value_block, opts, search_data)
      @label = label
      @value_block = value_block
      @classes = "col " << (opts[:class] || "")
      @sortable = opts[:sortable] || false
      @sort_by = opts[:sort_by] || ""
      @search_data = search_data
    end


    def value_for(record)
      @value_block.call(record)
    end


    def label
      @label
    end


    def sortable?
      @sortable
    end


    def sort_by
      @sort_by
    end


    def class
      @classes << " sortable" if sortable?
      @classes << " sort-#{@search_data.current_sort_direction}" if sortable? && @search_data.sorted_by === @sort_by
      @classes
    end

  end
end
