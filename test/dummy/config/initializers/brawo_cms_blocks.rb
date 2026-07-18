Rails.application.config.to_prepare do
  BrawoCms.register_block_type :heading,
    label: 'Heading',
    fields: [
      { name: :text, type: :string, label: 'Heading Text', required: true },
      { name: :level, type: :select, label: 'Level', choices: [['H1', 1], ['H2', 2], ['H3', 3]] }
    ]

  BrawoCms.register_block_type :text,
    label: 'Text',
    fields: [
      { name: :body, type: :textarea, label: 'Body Text' }
    ]

  BrawoCms.register_block_type :faq,
    label: 'FAQ Section',
    fields: [
      { name: :section_title, type: :string, label: 'Section Title' },
      {
        name: :items,
        type: :repeater,
        label: 'FAQ Items',
        sub_fields: [
          { name: :question, type: :string, label: 'Question' },
          { name: :answer, type: :textarea, label: 'Answer' }
        ]
      }
    ]
end
