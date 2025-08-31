ActiveAdmin.register_page "SQL Query Executor" do
  menu priority: 100, label: "SQL Query"

  page_action :index do
    query_result = execute_sql_query if params[:sql_query].present?
    render "sql_query/index", layout: "active_admin", locals: { query_result: query_result }
  end

  controller do
    private

    def execute_sql_query
      query = params[:sql_query].strip
      
      # Security validation - only allow SELECT statements
      unless query.match(/\A\s*SELECT\s+/i)
        return { 
          error: "Only SELECT queries are allowed. DELETE, UPDATE, INSERT, DROP, ALTER, CREATE, and other write operations are prohibited." 
        }
      end

      # Additional security checks
      dangerous_keywords = %w[DELETE UPDATE INSERT DROP ALTER CREATE TRUNCATE EXEC EXECUTE]
      if dangerous_keywords.any? { |keyword| query.match(/\b#{keyword}\b/i) }
        return { 
          error: "Query contains prohibited keywords. Only SELECT statements are allowed." 
        }
      end

      begin
        # Execute the query with a safety row limit if not already present
        safe_query = query
        unless query.match(/\bLIMIT\s+\d+/i)
          safe_query = "#{query} LIMIT 1000"
        end
        
        result = ActiveRecord::Base.connection.execute(safe_query)
        
        # Convert PG::Result to array of arrays for table_for compatibility
        result_data = []
        result.each do |row|
          row_data = result.fields.map do |field|
            value = row[field]
            # Ensure all values are properly typed
            value
          end
          result_data << row_data
        end
        
        {
          query: safe_query,
          result: result_data,
          row_count: result.ntuples,
          column_names: result.fields
        }
      rescue => e
        { error: "Database Error: #{e.message}" }
      end
    rescue => e
      { error: e.message }
    end
  end
end