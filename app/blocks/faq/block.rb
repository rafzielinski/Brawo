label "FAQ Section"

field :section_title, type: :string, label: "Section Title"
field :items, type: :repeater, label: "FAQ Items", sub_fields: [
  { name: :question, type: :string, label: "Question" },
  { name: :answer, type: :textarea, label: "Answer" }
]
