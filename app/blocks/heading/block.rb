label "Heading"

field :text, type: :string, label: "Heading Text", required: true
field :level, type: :select, label: "Level", choices: [["H1", 1], ["H2", 2], ["H3", 3]]
