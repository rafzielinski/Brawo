class Page < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :page,
    label: 'Page',
    page_builder: true,
    fields: [
      { name: :blocks, type: :blocks, label: 'Page Content' }
    ]
end
