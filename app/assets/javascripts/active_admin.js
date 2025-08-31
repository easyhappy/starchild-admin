//= require active_admin/base
//= require chartkick
//= require Chart.bundle

const loadRJS = (path) => {
    $.ajax({
      type: "get",
      dataType: 'script',
      url: path,
    })
}

const pollingRJS = (path, interval) => {
    timer = setInterval(() => loadRJS(path), interval);

    window.onbeforeunload = function () {
        clearInterval(timer);
    };
}

$(document).ready(function() {
  // Safe timeago initialization
  try {
    if (typeof $.fn.timeago === 'function') {
      $("time.timeago").timeago();
    }
  } catch (e) {
    console.warn('Timeago function not available:', e);
  }
  
  // Initialize custom categories multi-select with multiple attempts
  initializeCategoriesMultiSelect();
  
  // Also try after a delay in case DOM is not fully ready
  setTimeout(function() {
    initializeCategoriesMultiSelect();
  }, 500);
  
  // And one more time after page is fully loaded
  setTimeout(function() {
    initializeCategoriesMultiSelect();
  }, 1000);
});

// Also initialize when the window loads (as a backup)
$(window).on('load', function() {
  setTimeout(function() {
    initializeCategoriesMultiSelect();
  }, 200);
});

// Global function to manually initialize categories (for debugging)
window.initCategories = function() {
  console.log('Manual categories initialization...');
  $('.categories-multiselect').removeClass('initialized');
  initializeCategoriesMultiSelect();
};

// Global function to test category selection (for debugging)
window.testCategorySelection = function(categoryName) {
  console.log('Testing category selection for:', categoryName);
  const $option = $(`.category-option[data-value="${categoryName}"]`);
  if ($option.length > 0) {
    console.log('Found option:', $option.attr('class'));
    $option.click();
  } else {
    console.log('Option not found');
  }
};

// Global function to check current state
window.checkCategoriesState = function() {
  console.log('=== Categories State Check ===');
  const $container = $('.categories-multiselect');
  console.log('Container found:', $container.length);
  console.log('Container initialized:', $container.hasClass('initialized'));
  
  const $options = $('.category-option');
  console.log('Total options:', $options.length);
  
  $options.each(function(i, option) {
    const $opt = $(option);
    console.log(`Option ${i + 1}: ${$opt.data('value')} - Classes: ${$opt.attr('class')}`);
  });
  
  const $select = $('.categories-multiselect-hidden');
  console.log('Hidden select found:', $select.length);
  console.log('Selected values:', $select.val());
};

// Custom Categories Multi-Select Functionality
function initializeCategoriesMultiSelect() {
  console.log('Initializing categories multi-select...');
  const $multiselect = $('.categories-multiselect');
  console.log('Found multiselect containers:', $multiselect.length);
  
  if ($multiselect.length === 0) {
    console.log('No categories-multiselect containers found');
    return;
  }
  
  // Check if already initialized to prevent double initialization
  if ($multiselect.hasClass('initialized')) {
    console.log('Categories multi-select already initialized');
    return;
  }
  
  const $originalSelect = $multiselect.find('select.categories-multiselect-hidden');
  console.log('Found hidden select elements:', $originalSelect.length);
  
  if ($originalSelect.length === 0) {
    // Try to find any select element and add the class
    const $anySelect = $multiselect.find('select');
    console.log('Found any select elements:', $anySelect.length);
    if ($anySelect.length > 0) {
      $anySelect.addClass('categories-multiselect-hidden');
      setupCategoriesInterface($multiselect, $anySelect);
      return;
    }
    console.log('No select elements found in categories-multiselect');
    return;
  }
  
  setupCategoriesInterface($multiselect, $originalSelect);
}

function setupCategoriesInterface($container, $select) {
  console.log('Setting up categories interface...');
  
  // Mark as initialized
  $container.addClass('initialized');
  
  // Initialize the selected display and sync visual state
  updateSelectedCategoriesDisplay($container, $select);
  syncVisualStateWithSelect($container, $select);
  
  // Set up event handlers
  setupCategoriesClickHandlers($container, $select);
  
  console.log('Categories multi-select setup complete');
}

function getSelectedValues($select) {
  return $select.val() || [];
}

function syncVisualStateWithSelect($container, $select) {
  const selectedValues = getSelectedValues($select);
  console.log('Syncing visual state with selected values:', selectedValues);
  
  // Remove all selected classes first
  $container.find('.category-option').removeClass('selected');
  
  // Add selected class for currently selected values
  selectedValues.forEach(value => {
    const $option = $container.find(`.category-option[data-value="${value}"]`);
    if ($option.length > 0) {
      $option.addClass('selected');
      console.log('Marked as selected:', value);
    }
  });
}

function setupCategoriesClickHandlers($container, $select) {
  console.log('Setting up click handlers...');
  console.log('Container:', $container.length, 'Select:', $select.length);
  console.log('Category options found:', $container.find('.category-option').length);
  
  // Remove any existing handlers to prevent duplicates
  $container.off('click', '.category-option');
  $container.off('click', '.remove-btn');
  
  // Test direct click binding as backup
  $container.find('.category-option').each(function() {
    const $option = $(this);
    console.log('Setting up direct click for:', $option.data('value'));
    $option.off('click').on('click', function(e) {
      handleCategoryClick(e, $(this), $container, $select);
    });
  });
  
  // Handle category option clicks (delegated event)
  $container.on('click', '.category-option', function(e) {
    handleCategoryClick(e, $(this), $container, $select);
  });
  
  // Set up remove button handlers
  setupRemoveButtonHandlers($container, $select);
}

// Separate function to handle category clicks
function handleCategoryClick(e, $option, $container, $select) {
  try {
    e.preventDefault();
    e.stopPropagation();
    
    const value = $option.data('value');
    const isSelected = $option.hasClass('selected');
    
    console.log('Category clicked:', value, 'Currently selected:', isSelected);
    console.log('Element classes before:', $option.attr('class'));
    
    // Force toggle the visual state immediately with animation
    if (isSelected) {
      // Deselect with animation
      $option.removeClass('selected just-selected').addClass('just-deselected');
      removeFromSelectElement($select, value);
      console.log('Deselected:', value);
      
      // Remove animation class after animation completes
      setTimeout(() => {
        $option.removeClass('just-deselected');
      }, 500);
    } else {
      // Select with animation
      $option.addClass('selected just-selected').removeClass('just-deselected');
      addToSelectElement($select, value);
      console.log('Selected:', value);
      
      // Remove animation class after animation completes
      setTimeout(() => {
        $option.removeClass('just-selected');
      }, 500);
    }
    
    console.log('Element classes after:', $option.attr('class'));
    
    // Update selected display
    updateSelectedCategoriesDisplay($container, $select);
    
    // Log current state
    console.log('Updated selected values:', getSelectedValues($select));
  } catch (error) {
    console.error('Error in category click handler:', error);
  }
}

// Set up remove button handlers (called from setupCategoriesClickHandlers)
function setupRemoveButtonHandlers($container, $select) {
  $container.on('click', '.remove-btn', function(e) {
    try {
      e.preventDefault();
      e.stopPropagation();
      
      const value = $(this).data('value');
      const $option = $container.find(`.category-option[data-value="${value}"]`);
      
      console.log('Removing from selected display:', value);
      
      // Animate deselection
      $option.removeClass('selected just-selected').addClass('just-deselected');  
      removeFromSelectElement($select, value);
      updateSelectedCategoriesDisplay($container, $select);
      
      // Remove animation class after animation completes
      setTimeout(() => {
        $option.removeClass('just-deselected');
      }, 500);
    } catch (error) {
      console.error('Error in remove button handler:', error);
    }
  });
}

function addToSelectElement($select, value) {
  const $option = $select.find(`option[value="${value}"]`);
  $option.prop('selected', true);
  console.log('Added to select:', value);
}

function removeFromSelectElement($select, value) {
  const $option = $select.find(`option[value="${value}"]`);
  $option.prop('selected', false);
  console.log('Removed from select:', value);
}

function updateSelectedCategoriesDisplay($container, $select) {
  const selectedValues = getSelectedValues($select);
  const $display = $container.find('.selected-categories');
  
  $display.empty();
  
  if (selectedValues.length === 0) {
    $display.append('<div style="color: #6c757d; font-style: italic;">No categories selected</div>');
    return;
  }
  
  selectedValues.forEach(value => {
    const $tag = $(`
      <span class="selected-category-tag">
        ${value}
        <span class="remove-btn" data-value="${value}">×</span>
      </span>
    `);
    $display.append($tag);
  });
}




/**
 * jQuery Editable Select
 * Indri Muska <indrimuska@gmail.com>
 *
 * Source on GitHub @ https://github.com/indrimuska/jquery-editable-select
 */

+(function ($) {
	// jQuery Editable Select
	EditableSelect = function (select, options) {
		var that     = this;
		
		this.options = options;
		this.$select = $(select);
		this.$input  = $('<input type="text" autocomplete="off">');
		this.$list   = $('<ul class="es-list">');
		this.utility = new EditableSelectUtility(this);
		
		if (['focus', 'manual'].indexOf(this.options.trigger) < 0) this.options.trigger = 'focus';
		if (['default', 'fade', 'slide'].indexOf(this.options.effects) < 0) this.options.effects = 'default';
		if (isNaN(this.options.duration) && ['fast', 'slow'].indexOf(this.options.duration) < 0) this.options.duration = 'fast';
		
		// create text input
		var events = $._data(select, "events");
		if (events) {
			Object.keys(events).forEach(key => {
				var event = events[key][0];
				this.$input.bind(event.type + "." + event.namespace, event.handler);
			});
		}
		this.$select.replaceWith(this.$input);
		this.$list.appendTo(this.options.appendTo || this.$input.parent());
		
		// initalization
		this.utility.initialize();
		this.utility.initializeList();
		this.utility.initializeInput();
		this.utility.trigger('created');
	}
	EditableSelect.DEFAULTS = { filter: true, effects: 'default', duration: 'fast', trigger: 'focus' };
	EditableSelect.prototype.filter = function () {
		var hiddens = 0;
		var search  = this.$input.val().toLowerCase().trim();
		
		this.$list.find('li').addClass('es-visible').show();
		if (this.options.filter) {
			hiddens = this.$list.find('li').filter(function (i, li) { return $(li).text().toLowerCase().indexOf(search) < 0; }).hide().removeClass('es-visible').length;
			if (this.$list.find('li').length == hiddens) this.hide();
		}
	};
	EditableSelect.prototype.show = function () {
		this.$list.css({
			top:   this.$input.position().top + this.$input.outerHeight() - 1,
			left:  this.$input.position().left,
			width: this.$input.outerWidth()
		});
		
		if (!this.$list.is(':visible') && this.$list.find('li.es-visible').length > 0) {
			var fns = { default: 'show', fade: 'fadeIn', slide: 'slideDown' };
			var fn  = fns[this.options.effects];
			
			this.utility.trigger('show');
			this.$input.addClass('open');
			this.$list[fn](this.options.duration, $.proxy(this.utility.trigger, this.utility, 'shown'));
		}
	};
	EditableSelect.prototype.hide = function () {
		var fns = { default: 'hide', fade: 'fadeOut', slide: 'slideUp' };
		var fn  = fns[this.options.effects];
		
		this.utility.trigger('hide');
		this.$input.removeClass('open');
		this.$list[fn](this.options.duration, $.proxy(this.utility.trigger, this.utility, 'hidden'));
	};
	EditableSelect.prototype.select = function ($li) {
		if (!this.$list.has($li) || !$li.is('li.es-visible:not([disabled])')) return;
		this.$input.val($li.text());
		if (this.options.filter) this.hide();
		this.filter();
		this.utility.trigger('select', $li);
	};
	EditableSelect.prototype.add = function (text, index, attrs, data) {
		var $li     = $('<li>').html(text);
		var $option = $('<option>').text(text);
		var last    = this.$list.find('li').length;
		
		if (isNaN(index)) index = last;
		else index = Math.min(Math.max(0, index), last);
		if (index == 0) {
		  this.$list.prepend($li);
		  this.$select.prepend($option);
		} else {
		  this.$list.find('li').eq(index - 1).after($li);
		  this.$select.find('option').eq(index - 1).after($option);
		}
		this.utility.setAttributes($li, attrs, data);
		this.utility.setAttributes($option, attrs, data);
		this.filter();
	};
	EditableSelect.prototype.remove = function (index) {
		var last = this.$list.find('li').length;
		
		if (isNaN(index)) index = last;
		else index = Math.min(Math.max(0, index), last - 1);
		this.$list.find('li').eq(index).remove();
		this.$select.find('option').eq(index).remove();
		this.filter();
	};
	EditableSelect.prototype.clear = function () {
		this.$list.find('li').remove();
		this.$select.find('option').remove();
		this.filter();
	};
	EditableSelect.prototype.destroy = function () {
		this.$list.off('mousemove mousedown mouseup');
		this.$input.off('focus blur input keydown');
		this.$input.replaceWith(this.$select);
		this.$list.remove();
		this.$select.removeData('editable-select');
	};
	
	// Utility
	EditableSelectUtility = function (es) {
		this.es = es;
	}
	EditableSelectUtility.prototype.initialize = function () {
		var that = this;
		that.setAttributes(that.es.$input, that.es.$select[0].attributes, that.es.$select.data());
		that.es.$input.addClass('es-input').data('editable-select', that.es);
		that.es.$select.find('option').each(function (i, option) {
			var $option = $(option).remove();
			that.es.add($option.text(), i, option.attributes, $option.data());
			if ($option.attr('selected')) that.es.$input.val($option.text());
		});
		that.es.filter();
	};
	EditableSelectUtility.prototype.initializeList = function () {
		var that = this;
		that.es.$list
			.on('mousemove', 'li:not([disabled])', function () {
				that.es.$list.find('.selected').removeClass('selected');
				$(this).addClass('selected');
			})
			.on('mousedown', 'li', function (e) {
				if ($(this).is('[disabled]')) e.preventDefault();
				else that.es.select($(this));
			})
			.on('mouseup', function () {
				that.es.$list.find('li.selected').removeClass('selected');
			});
	};
	EditableSelectUtility.prototype.initializeInput = function () {
		var that = this;
		switch (this.es.options.trigger) {
			default:
			case 'focus':
				that.es.$input
					.on('focus', $.proxy(that.es.show, that.es))
				        .on("blur", $.proxy(function() {
						if ($(".es-list:hover").length === 0) {
							that.es.hide();
						} else {
							this.$input.focus();
						}
					}, that.es
				    ));
				break;
			case 'manual':
				break;
		}
		that.es.$input.on('input keydown', function (e) {
			switch (e.keyCode) {
				case 38: // Up
					var visibles = that.es.$list.find('li.es-visible:not([disabled])');
					var selectedIndex = visibles.index(visibles.filter('li.selected'));
					that.highlight(selectedIndex - 1);
					e.preventDefault();
					break;
				case 40: // Down
					var visibles = that.es.$list.find('li.es-visible:not([disabled])');
					var selectedIndex = visibles.index(visibles.filter('li.selected'));
					that.highlight(selectedIndex + 1);
					e.preventDefault();
					break;
				case 13: // Enter
					if (that.es.$list.is(':visible')) {
						that.es.select(that.es.$list.find('li.selected'));
						e.preventDefault();
					}
					break;
				case 9:  // Tab
				case 27: // Esc
					that.es.hide();
					break;
				default:
					that.es.filter();
					that.highlight(0);
					break;
			}
		});
	};
	EditableSelectUtility.prototype.highlight = function (index) {
		var that = this;
		that.es.show();
		setTimeout(function () {
			var visibles         = that.es.$list.find('li.es-visible');
			var oldSelected      = that.es.$list.find('li.selected').removeClass('selected');
			var oldSelectedIndex = visibles.index(oldSelected);
			
			if (visibles.length > 0) {
				var selectedIndex = (visibles.length + index) % visibles.length;
				var selected      = visibles.eq(selectedIndex);
				var top           = selected.position().top;
				
				selected.addClass('selected');
				if (selectedIndex < oldSelectedIndex && top < 0)
					that.es.$list.scrollTop(that.es.$list.scrollTop() + top);
				if (selectedIndex > oldSelectedIndex && top + selected.outerHeight() > that.es.$list.outerHeight())
					that.es.$list.scrollTop(that.es.$list.scrollTop() + selected.outerHeight() + 2 * (top - that.es.$list.outerHeight()));
			}
		});
	};
	EditableSelectUtility.prototype.setAttributes = function ($element, attrs, data) {
		$.each(attrs || {}, function (i, attr) { $element.attr(attr.name, attr.value); });
		$element.data(data);
	};
	EditableSelectUtility.prototype.trigger = function (event) {
		var params = Array.prototype.slice.call(arguments, 1);
		var args   = [event + '.editable-select'];
		args.push(params);
		this.es.$select.trigger.apply(this.es.$select, args);
		this.es.$input.trigger.apply(this.es.$input, args);
	};
	
	// Plugin
	Plugin = function (option) {
		var args = Array.prototype.slice.call(arguments, 1);
		return this.each(function () {
			var $this   = $(this);
			var data    = $this.data('editable-select');
			var options = $.extend({}, EditableSelect.DEFAULTS, $this.data(), typeof option == 'object' && option);
			
			if (!data) data = new EditableSelect(this, options);
			if (typeof option == 'string') data[option].apply(data, args);
		});
	}
	$.fn.editableSelect             = Plugin;
	$.fn.editableSelect.Constructor = EditableSelect;
	
})(jQuery);