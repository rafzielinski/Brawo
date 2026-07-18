(function() {
  'use strict';

  function initRepeaterFields() {
    document.querySelectorAll('.repeater-field').forEach(function(repeaterField) {
      if (repeaterField.dataset.controller && repeaterField.dataset.controller.includes('repeater')) return;

      const fieldName = repeaterField.dataset.fieldName;
      const itemsContainer = repeaterField.querySelector('.repeater-items');
      const template = repeaterField.querySelector('.repeater-template');
      const addBtn = repeaterField.querySelector('.repeater-add-btn');

      if (!itemsContainer || !template || !addBtn) return;

      // Add button click handler
      addBtn.addEventListener('click', function() {
        addRepeaterRow(itemsContainer, template, fieldName);
      });

      // Remove button handlers (for existing rows)
      itemsContainer.querySelectorAll('.repeater-remove-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
          removeRepeaterRow(this);
        });
      });
    });
  }

  function addRepeaterRow(container, template, fieldName) {
    // Clone the template
    const newRow = template.cloneNode(true);
    newRow.classList.remove('repeater-template');
    newRow.style.display = '';

    // Get the next index
    const existingRows = container.querySelectorAll('.repeater-row:not(.repeater-template)');
    const nextIndex = existingRows.length;

    // Update all field names and IDs with the new index
    updateRowIndex(newRow, 'INDEX', nextIndex, fieldName);

    // Add remove button handler
    const removeBtn = newRow.querySelector('.repeater-remove-btn');
    if (removeBtn) {
      removeBtn.addEventListener('click', function() {
        removeRepeaterRow(this);
      });
    }

    // Insert before the template
    container.insertBefore(newRow, template);

    // Reindex all rows to ensure sequential indices
    reindexRows(container, fieldName);
  }

  function removeRepeaterRow(button) {
    const row = button.closest('.repeater-row');
    if (row) {
      const container = row.closest('.repeater-items');
      row.remove();
      
      // Reindex remaining rows
      if (container) {
        const fieldName = container.closest('.repeater-field').dataset.fieldName;
        reindexRows(container, fieldName);
      }
    }
  }

  function updateRowIndex(row, oldIndex, newIndex, fieldName) {
    // Update data-index attribute
    row.dataset.index = newIndex;

    // Update all input/select/textarea names and IDs
    row.querySelectorAll('input, select, textarea, label').forEach(function(element) {
      if (element.tagName === 'LABEL') {
        // Update label for attribute
        const forAttr = element.getAttribute('for');
        if (forAttr) {
          element.setAttribute('for', forAttr.replace(
            new RegExp('\\[' + oldIndex + '\\]', 'g'),
            '[' + newIndex + ']'
          ));
        }
      } else {
        // Update name and id attributes
        const name = element.getAttribute('name');
        const id = element.getAttribute('id');

        if (name) {
          element.setAttribute('name', name.replace(
            new RegExp('\\[' + oldIndex + '\\]', 'g'),
            '[' + newIndex + ']'
          ));
        }

        if (id) {
          element.setAttribute('id', id.replace(
            new RegExp('_' + oldIndex + '_', 'g'),
            '_' + newIndex + '_'
          ).replace(
            new RegExp('\\[' + oldIndex + '\\]', 'g'),
            '[' + newIndex + ']'
          ));
        }
      }
    });
  }

  function reindexRows(container, fieldName) {
    const rows = container.querySelectorAll('.repeater-row:not(.repeater-template)');
    rows.forEach(function(row, index) {
      const currentIndex = row.dataset.index;
      if (currentIndex !== index.toString()) {
        updateRowIndex(row, currentIndex, index, fieldName);
      }
    });
  }

  // Initialize on DOMContentLoaded
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initRepeaterFields);
  } else {
    initRepeaterFields();
  }

  // Also initialize on Turbo events if Turbo is available
  if (typeof Turbo !== 'undefined') {
    document.addEventListener('turbo:load', initRepeaterFields);
    document.addEventListener('turbo:frame-load', initRepeaterFields);
  }
})();


