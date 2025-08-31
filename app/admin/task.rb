ActiveAdmin.register Task do
  menu priority: 5, label: "Task"

  actions :index, :show, :edit, :update, :stats
  filter :user_id
  filter :status
  filter :categories, as: :select,
          collection: ["Indicator Hub", "Strategy Lab", "Signal Scanner", "KOL Radar", "Auto Briefing", "Market Pulse", "Token Deep Dive", "Others"],
          multiple: true
  filter :title
  filter :display_user_name
  filter :task_id
  filter :id
  filter :task_type

  permit_params :user_id, :display_user_name, :display_user_avatar, :tokens, :tags, :title, :description, categories: []

  index do
    selectable_column
    column :id
    column :task_id
    column :user_id
    column :user_name
    column :task_type
    column :title
    column :description
    column :status
    column :interval
    column :trigger_type
    column :categories
    column :tags
    column :tokens
    column :updated_at
    actions defaults: true, id_param: :id
  end

  show do
    attributes_table do
      row :id
      row :task_id
      row :user_id
      row :user_name
      row :task_type
      row :title
      row :description
      row :cn_title
      row :cn_description
      row :en_title
      row :en_description
      row :status
      row :interval
      row :trigger_type
      row :categories do |task|
        if task.categories.is_a?(Array)
          task.categories.join(", ")
        elsif task.categories.is_a?(String)
          begin
            parsed = JSON.parse(task.categories)
            parsed.is_a?(Array) ? parsed.join(", ") : task.categories
          rescue JSON::ParserError
            task.categories
          end
        else
          task.categories.to_s
        end
      end
      row :tags
      row :tokens
      row :updated_at
      row :human_code
      row :human_trigger_history
      row :subscribed_user_ids
      row :image_url
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs "Task Details" do
      f.input :title, as: :string, label: "Title", hint: "Task title"
      f.input :description, as: :string, label: "Description", hint: "Task description"
      f.input :categories, as: :select,
              collection: ["Indicator Hub", "Strategy Lab", "Signal Scanner", "KOL Radar", "Auto Briefing", "Market Pulse", "Token Deep Dive", "Others"],
              selected: f.object.categories.is_a?(Array) ? f.object.categories : (f.object.categories.present? ? (JSON.parse(f.object.categories.to_s) rescue []) : []),
              input_html: {
                multiple: true,
                class: "categories-multiselect-hidden",
                id: "task_categories_select"
              },
              wrapper_html: { class: "categories-multiselect" },
              label: "Categories"

      # Custom categories grid
      li class: "categories-grid-container" do
        div class: "categories-grid" do
          ["Indicator Hub", "Strategy Lab", "Signal Scanner", "KOL Radar", "Auto Briefing", "Market Pulse", "Token Deep Dive", "Others"].each do |category|
            current_categories = f.object.categories.is_a?(Array) ? f.object.categories : (f.object.categories.present? ? (JSON.parse(f.object.categories.to_s) rescue []) : [])
            selected_class = current_categories.include?(category) ? "selected" : ""
            div class: "category-option #{selected_class}", "data-value": category do
              category
            end
          end
        end

        # Selected categories display
        div class: "selected-categories" do
          # Will be populated by JavaScript
        end

        p class: "inline-hints" do
          "Click categories above to select/deselect them"
        end

        # Inline CSS for categories styling
        style type: "text/css" do
          raw <<~CSS
            .categories-grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
              gap: 8px;
              margin-bottom: 10px;
            }

            .category-option {
              background: #f8f9fa;
              border: 2px solid #e9ecef;
              border-radius: 8px;
              padding: 12px 16px;
              cursor: pointer;
              text-align: center;
              font-weight: 500;
              transition: all 0.3s ease;
              user-select: none;
            }

            .category-option:hover {
              background: #e9ecef;
              border-color: #dee2e6;
              transform: translateY(-1px);
            }

            .category-option.selected {
              background: #22c55e !important;
              border-color: #22c55e !important;
              color: white !important;
              font-weight: 600;
              transform: translateY(-1px);
              box-shadow: 0 4px 12px rgba(34, 197, 94, 0.4);
            }

            .category-option.selected::after {
              content: " ✓";
              font-weight: bold;
              margin-left: 4px;
            }

            .category-option.selected:hover {
              background: #16a34a !important;
              border-color: #16a34a !important;
              transform: translateY(-2px);
              box-shadow: 0 6px 16px rgba(34, 197, 94, 0.5);
            }

            .selected-categories {
              margin-top: 10px;
            }

            .selected-category-tag {
              display: inline-block;
              background: #22c55e;
              color: white;
              padding: 4px 8px;
              margin: 2px 4px 2px 0;
              border-radius: 4px;
              font-size: 12px;
            }

            .remove-btn {
              margin-left: 6px;
              cursor: pointer;
              font-weight: bold;
            }

            .remove-btn:hover {
              color: #ffcccc;
            }

            .categories-multiselect-hidden {
              display: none !important;
            }
          CSS
        end

        # Inline JavaScript for categories functionality
        script type: "text/javascript" do
          raw <<~JAVASCRIPT
            $(document).ready(function() {
              console.log('Initializing inline categories functionality...');

              // Global debug functions
              window.checkCategoriesState = function() {
                console.log('=== Categories State Check ===');
                const $container = $('.categories-multiselect');
                console.log('Container found:', $container.length);

                const $options = $('.category-option');
                console.log('Total options:', $options.length);

                $options.each(function(i, option) {
                  const $opt = $(option);
                  console.log('Option ' + (i + 1) + ': ' + $opt.data('value') + ' - Classes: ' + $opt.attr('class'));
                });

                const $select = $('#task_categories_select');
                console.log('Hidden select found:', $select.length);
                console.log('Select element id:', $select.attr('id'));
                console.log('Select element name:', $select.attr('name'));
                console.log('Selected values:', $select.val());
                console.log('All options in select:', $select.find('option').map(function() { return $(this).val() + ':' + $(this).prop('selected'); }).get());
              };

              window.testCategorySelection = function(categoryName) {
                console.log('Testing category selection for:', categoryName);
                const $option = $('.category-option[data-value="' + categoryName + '"]');
                if ($option.length > 0) {
                  console.log('Found option:', $option.attr('class'));
                  $option.click();
                } else {
                  console.log('Option not found');
                }
              };

              // Setup category click handlers
              $('.category-option').on('click', function(e) {
                e.preventDefault();
                console.log('Category clicked!');

                const $option = $(this);
                const value = $option.data('value');
                const isSelected = $option.hasClass('selected');

                console.log('Category:', value, 'Currently selected:', isSelected);
                console.log('Classes before:', $option.attr('class'));

                const $select = $('#task_categories_select');
                console.log('Select element found:', $select.length);
                console.log('Select element name attr:', $select.attr('name'));

                if (isSelected) {
                  // Deselect
                  $option.removeClass('selected');
                  const $optionElement = $select.find('option[value="' + value + '"]');
                  console.log('Option element to deselect:', $optionElement.length);
                  $optionElement.prop('selected', false);
                  console.log('Deselected:', value);
                } else {
                  // Select
                  $option.addClass('selected');
                  const $optionElement = $select.find('option[value="' + value + '"]');
                  console.log('Option element to select:', $optionElement.length);
                  $optionElement.prop('selected', true);
                  console.log('Selected:', value);
                }

                // Force trigger change event
                $select.trigger('change');

                console.log('Classes after:', $option.attr('class'));
                console.log('Select values:', $select.val());

                // Update display
                updateSelectedDisplay();
              });

              function updateSelectedDisplay() {
                const $display = $('.selected-categories');
                const $select = $('#task_categories_select');
                const selectedValues = $select.val() || [];

                $display.empty();

                if (selectedValues.length === 0) {
                  $display.append('<div style="color: #6c757d; font-style: italic;">No categories selected</div>');
                  return;
                }

                selectedValues.forEach(function(value) {
                  const $tag = $('<span class="selected-category-tag">' + value + ' <span class="remove-btn" data-value="' + value + '">×</span></span>');
                  $display.append($tag);
                });
              }

              // Handle remove button clicks
              $(document).on('click', '.remove-btn', function(e) {
                e.preventDefault();
                const value = $(this).data('value');
                const $option = $('.category-option[data-value="' + value + '"]');
                const $select = $('#task_categories_select');

                $option.removeClass('selected');
                $select.find('option[value="' + value + '"]').prop('selected', false);

                updateSelectedDisplay();
              });

              // Initial setup
              updateSelectedDisplay();

              // Debug form submission
              $('form').on('submit', function() {
                console.log('Form submitting...');
                const $select = $('#task_categories_select');
                const selectedValues = $select.val();
                console.log('Categories being submitted:', selectedValues);
                console.log('Select element HTML:', $select.prop('outerHTML'));
              });

              console.log('Categories functionality initialized. Try: checkCategoriesState()');
            });
          JAVASCRIPT
        end
      end
    end

    f.inputs "Tags and Tokens" do
      f.input :tags, as: :string,
              input_html: {
                value: f.object.tags.is_a?(Array) ? f.object.tags.to_json : (f.object.tags || "[]").to_s,
                id: "task_tags_input"
              },
              label: "Tags",
              hint: "Enter tags as JSON array, e.g., [\"RSI\", \"MACD\"] or type to search tokens"

      f.input :tokens, as: :string,
              input_html: {
                value: f.object.tokens.is_a?(Array) ? f.object.tokens.to_json : (f.object.tokens || "[]").to_s
              },
              label: "Tokens",
              hint: "Enter tokens as JSON array, e.g., [\"BTC\", \"ETH\"]"
    end

    f.actions
  end

  controller do
    def update
      puts "=== UPDATE METHOD CALLED ==="
      puts "params: #{params}"
      puts "permitted_params: #{permitted_params}"

      # Get the permitted parameters
      task_params = permitted_params[:task]
      puts "task_params: #{task_params}"

      # Handle JSON parsing for tags
      if task_params[:tags].present?
        puts "Original tags: #{task_params[:tags]}"
        begin
          if task_params[:tags].is_a?(String)
            task_params[:tags] = JSON.parse(task_params[:tags])
            puts "Parsed tags: #{task_params[:tags]}"
          end
        rescue JSON::ParserError
          puts "JSON parse error for tags"
          flash[:error] = "Invalid JSON format for tags. Please use valid JSON array format."
          redirect_back(fallback_location: admin_tasks_path) and return
        end
      end

      # Handle JSON parsing for tokens
      if task_params[:tokens].present?
        puts "Original tokens: #{task_params[:tokens]}"
        begin
          if task_params[:tokens].is_a?(String)
            task_params[:tokens] = JSON.parse(task_params[:tokens])
            puts "Parsed tokens: #{task_params[:tokens]}"
          end
        rescue JSON::ParserError
          puts "JSON parse error for tokens"
          flash[:error] = "Invalid JSON format for tokens. Please use valid JSON array format."
          redirect_back(fallback_location: admin_tasks_path) and return
        end
      end

      # Handle categories from multi-select
      puts "Categories param present: #{task_params[:categories].present?}"
      puts "Categories param class: #{task_params[:categories].class}"
      puts "Categories param value: #{task_params[:categories].inspect}"

      if task_params[:categories].present?
        puts "Original categories: #{task_params[:categories]}"
        if task_params[:categories].is_a?(Array)
          # Filter out empty strings and keep only valid categories
          task_params[:categories] = task_params[:categories].reject(&:blank?)
          puts "Processed categories array: #{task_params[:categories]}"
        elsif task_params[:categories].is_a?(String)
          # Handle case where it might still come as JSON string
          begin
            task_params[:categories] = JSON.parse(task_params[:categories])
            puts "Parsed categories from JSON: #{task_params[:categories]}"
          rescue JSON::ParserError
            puts "JSON parse error for categories"
            flash[:error] = "Invalid JSON format for categories. Please use valid JSON array format."
            redirect_back(fallback_location: admin_tasks_path) and return
          end
        end
      else
        # Set empty array if no categories selected
        puts "No categories selected, setting empty array"
        task_params[:categories] = []
      end

      puts "Final categories value: #{task_params[:categories].inspect}"

      # Keep categories as array for database storage (database handles JSON conversion)
      # No need to manually convert to JSON string - Rails/PostgreSQL handles this automatically

      # Update the resource directly with parsed parameters
      puts "Updating resource with final params: #{task_params}"
      if resource.update(task_params)
        puts "Resource updated successfully"
        redirect_to resource_path(resource), notice: 'Task was successfully updated.'
      else
        puts "Resource update failed: #{resource.errors.full_messages}"
        flash[:error] = resource.errors.full_messages.join(', ')
        render :edit
      end
    end

    def index
      # Set default categories filter if no filter parameters are present
      if params[:q].blank? || params[:q][:categories_in].blank?
        params[:q] ||= {}
        # Set default selected categories - modify these as needed
        params[:q][:categories_in] = []  # Add default categories here, e.g., ["Indicator Hub", "Strategy Lab"]
      end
      
      super
    end

    def show
      super
    end

    def edit
      super
    end

    before_action :check_permissions

    def check_permissions
      authorize! :manage, Task
    end

    # Custom filter for categories (JSON array)
    def scoped_collection
      # Store categories filter before calling super to prevent duplicate filtering
      categories_filter = nil
      if params[:q] && params[:q][:categories_in].present?
        categories_filter = Array(params[:q][:categories_in]).reject(&:blank?)
        # Remove categories_in from params to prevent ActiveAdmin's default filtering
        params[:q].delete(:categories_in)
      end
      
      collection = super
      
      if categories_filter&.any?
        begin
          # Build custom JSON array filter conditions
          conditions = categories_filter.map { "categories @> ?::jsonb" }.join(" OR ")
          params_array = categories_filter.map { |cat| [cat].to_json }
          
          # Apply custom filtering with proper error handling
          collection = collection.where(conditions, *params_array)
        rescue StandardError => e
          Rails.logger.error "Failed to filter categories: #{e.message}"
          Rails.logger.error "Categories filter error details: #{e.backtrace.first(5).join('\n')}"
          # Return unfiltered collection on error to prevent breaking the page
        end
      end
      
      collection
    end
  end
end
