require 'rails_helper'

RSpec.describe BrawoCms::Admin::FieldWrapperHelper, type: :helper do
  describe '#normalize_field_width' do
    it 'defaults to 100%' do
      expect(helper.normalize_field_width(nil)).to eq('100%')
      expect(helper.normalize_field_width('')).to eq('100%')
      expect(helper.normalize_field_width('100')).to eq('100%')
    end

    it 'converts numeric strings to percentages' do
      expect(helper.normalize_field_width('50')).to eq('50%')
      expect(helper.normalize_field_width(33)).to eq('33%')
    end

    it 'preserves explicit percentage values' do
      expect(helper.normalize_field_width('75%')).to eq('75%')
    end
  end

  describe '#field_bootstrap_col_class' do
    it 'maps percentages to Bootstrap columns' do
      expect(helper.field_bootstrap_col_class(100)).to eq('col-12')
      expect(helper.field_bootstrap_col_class(50)).to eq('col-12 col-md-6')
      expect(helper.field_bootstrap_col_class(33)).to eq('col-12 col-md-4')
      expect(helper.field_bootstrap_col_class(25)).to eq('col-12 col-md-3')
    end
  end

  describe '#field_wrapper_attrs' do
    it 'returns default full-width wrapper attrs' do
      attrs = helper.field_wrapper_attrs(name: :title, type: :string)

      expect(attrs[:class]).to eq('brawo-field-wrapper col-12 mb-3')
      expect(attrs[:style]).to be_nil
      expect(attrs[:data][:field_width]).to eq('100')
    end

    it 'merges wrapper width, class, and hash attrs' do
      field = {
        name: :author,
        type: :string,
        wrapper: {
          width: '50',
          class: 'custom-class',
          attr: { 'data-test' => 'author' }
        }
      }

      attrs = helper.field_wrapper_attrs(field)

      expect(attrs[:class]).to eq('brawo-field-wrapper col-12 col-md-6 mb-3 custom-class')
      expect(attrs[:style]).to be_nil
      expect(attrs[:data][:field_width]).to eq('50')
      expect(attrs['data-test']).to eq('author')
    end

    it 'parses string attr values' do
      field = {
        name: :author,
        type: :string,
        wrapper: {
          attr: 'data-custom-attr="custom-value" data-foo="bar"'
        }
      }

      attrs = helper.field_wrapper_attrs(field)

      expect(attrs['data-custom-attr']).to eq('custom-value')
      expect(attrs['data-foo']).to eq('bar')
    end
  end
end
